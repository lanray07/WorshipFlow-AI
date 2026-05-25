import AVFoundation
import Foundation
import Observation
import Speech

enum VoiceInputError: LocalizedError {
    case recognizerUnavailable
    case notAuthorized
    case audioUnavailable

    var errorDescription: String? {
        switch self {
        case .recognizerUnavailable:
            "Speech recognition is not available right now."
        case .notAuthorized:
            "Microphone and speech recognition permissions are required for voice input."
        case .audioUnavailable:
            "The microphone could not be started."
        }
    }
}

@MainActor
@Observable
final class VoiceInputService {
    var transcript = ""
    var isListening = false
    var errorMessage: String?

    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en_GB"))
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    func requestAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }

    func start() async {
        guard !isListening else { return }
        guard await requestAuthorization() else {
            errorMessage = VoiceInputError.notAuthorized.localizedDescription
            return
        }
        guard recognizer?.isAvailable == true else {
            errorMessage = VoiceInputError.recognizerUnavailable.localizedDescription
            return
        }

        do {
            try configureAudioSession()
            try startRecognition()
            isListening = true
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
            stop()
        }
    }

    func stop() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
        isListening = false
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func configureAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement, options: [.duckOthers])
        try session.setActive(true, options: .notifyOthersOnDeactivation)
    }

    private func startRecognition() throws {
        recognitionTask?.cancel()
        recognitionTask = nil
        transcript = ""

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        recognitionRequest = request

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak request] buffer, _ in
            request?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        recognitionTask = recognizer?.recognitionTask(with: request) { [weak self] result, error in
            Task { @MainActor in
                if let result {
                    self?.transcript = result.bestTranscription.formattedString
                }
                if error != nil || result?.isFinal == true {
                    self?.stop()
                }
            }
        }
    }
}
