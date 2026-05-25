import SwiftUI

struct VoiceInputButton: View {
    @Binding var text: String
    var prompt: String = "Voice input"
    var appendMode = false

    @State private var voiceInput = VoiceInputService()
    @State private var baselineText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                Task { await toggleListening() }
            } label: {
                Label(voiceInput.isListening ? "Stop Listening" : prompt, systemImage: voiceInput.isListening ? "stop.circle.fill" : "mic.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(voiceInput.isListening ? .red : WFColor.gold)
            .onChange(of: voiceInput.transcript) { _, transcript in
                guard !transcript.isEmpty else { return }
                if appendMode && !baselineText.isEmpty {
                    text = "\(baselineText) \(transcript)"
                } else {
                    text = transcript
                }
            }

            if voiceInput.isListening {
                Label("Listening...", systemImage: "waveform")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(WFColor.softGold)
            }

            if let error = voiceInput.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red.opacity(0.9))
            }
        }
    }

    private func toggleListening() async {
        if voiceInput.isListening {
            voiceInput.stop()
        } else {
            baselineText = text
            await voiceInput.start()
        }
    }
}
