import Foundation

struct AISuggestionBundle: Codable, Hashable {
    var flowSuggestions: [String]
    var transitionNotes: [String]
    var recommendedKeys: [String]
    var summary: String
}

protocol AIService {
    func generateSetFlowSuggestions(worshipStyle: String, setList: [Song], serviceNotes: String) async throws -> AISuggestionBundle
    func generateTransitionNotes(from firstSong: Song, to secondSong: Song) async throws -> String
    func generateRehearsalNotes(setList: SetList, songs: [Song]) async throws -> [String]
    func suggestSongKeys(song: Song, vocalistRange: String) async throws -> [String]
    func generateServiceFlowInsights(setList: SetList, songs: [Song], volunteers: [Volunteer]) async throws -> String
}

struct MockAIService: AIService {
    func generateSetFlowSuggestions(worshipStyle: String, setList: [Song], serviceNotes: String) async throws -> AISuggestionBundle {
        let titles = setList.map(\.title).joined(separator: ", ")
        return AISuggestionBundle(
            flowSuggestions: [
                "Open with a clear tempo count-in and keep the first transition simple.",
                "Group songs with nearby keys to reduce retuning and vocal strain.",
                "Use one short spoken cue before the closing song to steady the room."
            ],
            transitionNotes: [
                "Pad in the outgoing key while acoustic guitar prepares the next tempo.",
                "Let the vocal lead cue the final chorus before the band resolves."
            ],
            recommendedKeys: setList.map { "\($0.title): \($0.originalKey) or one whole step lower" },
            summary: "Mock AI reviewed \(titles.isEmpty ? "the current set" : titles) for a \(worshipStyle.lowercased()) service. These are optional planning recommendations, not ministry decisions."
        )
    }

    func generateTransitionNotes(from firstSong: Song, to secondSong: Song) async throws -> String {
        "Move from \(firstSong.title) to \(secondSong.title) with a sustained pad, two-bar count, and a clear vocal cue."
    }

    func generateRehearsalNotes(setList: SetList, songs: [Song]) async throws -> [String] {
        [
            "Confirm intros, endings, and leader cues before running the full set.",
            "Mark any lyric repeats that need projection attention.",
            "Sound team should check lead vocal, click, and acoustic levels before rehearsal starts."
        ]
    }

    func suggestSongKeys(song: Song, vocalistRange: String) async throws -> [String] {
        ["\(song.originalKey) original", "One step down for comfort", "Capo 2 using G shapes"]
    }

    func generateServiceFlowInsights(setList: SetList, songs: [Song], volunteers: [Volunteer]) async throws -> String {
        "The service flow is strongest when rehearsal confirms \(songs.count) songs, \(volunteers.count) volunteers, transitions, and projection cues before Sunday."
    }
}

struct RemoteAIService: AIService {
    private let endpoint = URL(string: "https://YOUR_BACKEND_URL.com/worshipflow-ai")!
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func generateSetFlowSuggestions(worshipStyle: String, setList: [Song], serviceNotes: String) async throws -> AISuggestionBundle {
        let payload = RemoteAIRequest(
            module: "setList",
            worshipStyle: worshipStyle,
            setList: setList.map(\.title),
            songKeys: setList.map(\.originalKey),
            serviceNotes: serviceNotes
        )
        return try await perform(payload)
    }

    func generateTransitionNotes(from firstSong: Song, to secondSong: Song) async throws -> String {
        let response = try await perform(RemoteAIRequest(module: "transition", worshipStyle: "", setList: [firstSong.title, secondSong.title], songKeys: [firstSong.originalKey, secondSong.originalKey], serviceNotes: ""))
        return response.transitionNotes.first ?? response.summary
    }

    func generateRehearsalNotes(setList: SetList, songs: [Song]) async throws -> [String] {
        let response = try await perform(RemoteAIRequest(module: "rehearsal", worshipStyle: "", setList: songs.map(\.title), songKeys: songs.map(\.originalKey), serviceNotes: setList.notes))
        return response.flowSuggestions
    }

    func suggestSongKeys(song: Song, vocalistRange: String) async throws -> [String] {
        let response = try await perform(RemoteAIRequest(module: "keys", worshipStyle: "", setList: [song.title], songKeys: [song.originalKey], serviceNotes: vocalistRange))
        return response.recommendedKeys
    }

    func generateServiceFlowInsights(setList: SetList, songs: [Song], volunteers: [Volunteer]) async throws -> String {
        let response = try await perform(RemoteAIRequest(module: "serviceFlow", worshipStyle: "", setList: songs.map(\.title), songKeys: songs.map(\.originalKey), serviceNotes: "\(setList.notes) Volunteers: \(volunteers.map(\.fullName).joined(separator: ", "))"))
        return response.summary
    }

    private func perform(_ payload: RemoteAIRequest) async throws -> AISuggestionBundle {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(payload)
        let (data, _) = try await session.data(for: request)
        return try JSONDecoder().decode(AISuggestionBundle.self, from: data)
    }
}

private struct RemoteAIRequest: Encodable {
    var module: String
    var worshipStyle: String
    var setList: [String]
    var songKeys: [String]
    var serviceNotes: String
}

enum WorshipFlowAIPrompt {
    static let internalPrompt = "You are WorshipFlow AI, a worship planning assistant. Help worship teams organize services, improve musical flow, coordinate rehearsals, and simplify scheduling using respectful, supportive language. Do not generate theological authority claims or denominational rulings."
    static let disclaimer = "WorshipFlow AI is an organizational and planning tool only. Users remain responsible for ministry decisions. AI suggestions are optional recommendations."
}
