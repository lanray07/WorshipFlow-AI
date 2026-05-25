import Foundation
import Observation
import SwiftData

enum AppRoute: Hashable {
    case setListBuilder
    case songLibrary
    case transposer
    case lyricPrompter
    case scheduler
    case rehearsal
    case serviceTimeline
    case messaging
    case analytics
    case exports
    case paywall
    case settings
}

@MainActor
@Observable
final class AppViewModel {
    var path: [AppRoute] = []
    var isLoading = false
    var errorMessage: String?
    var aiSuggestions: AISuggestionBundle?
    var selectedPDFURL: URL?

    private let aiService: AIService
    private let pdfService: PDFExportService
    private let syncEngine: SyncEngine

    init(
        aiService: AIService = MockAIService(),
        pdfService: PDFExportService = PDFExportService(),
        syncEngine: SyncEngine = LocalOnlySyncEngine()
    ) {
        self.aiService = aiService
        self.pdfService = pdfService
        self.syncEngine = syncEngine
    }

    func seedIfNeeded(context: ModelContext) {
        let songDescriptor = FetchDescriptor<Song>()
        guard (try? context.fetch(songDescriptor).isEmpty) == true else { return }

        let songs = [
            Song(
                title: "Morning Praise",
                artist: "WorshipFlow Demo",
                originalKey: "G",
                bpm: 104,
                lyrics: "Verse 1\nWe gather with expectant hearts\n\nChorus\nLift every voice as one\n\nBridge\nSteady our rhythm, guide our song",
                chordChart: "[G] We gather with [D] expectant hearts\n[Em] Ready for [C] Sunday"
            ),
            Song(
                title: "Steady Light",
                artist: "WorshipFlow Demo",
                originalKey: "D",
                bpm: 72,
                lyrics: "Verse\nQuiet every hurried thought\n\nChorus\nYou are our steady light\n\nTag\nLead us in peace",
                chordChart: "[D] Quiet every [A] hurried thought\n[Bm] Lead us in [G] peace"
            ),
            Song(
                title: "Sending Song",
                artist: "WorshipFlow Demo",
                originalKey: "A",
                bpm: 118,
                lyrics: "Verse\nHands open, voices bright\n\nChorus\nWe go with hope alive",
                chordChart: "[A] Hands open [E] voices bright\n[F#m] Hope alive [D] today"
            )
        ]

        let setList = SetList(title: "Sunday Worship Flow", serviceDate: Calendar.current.date(byAdding: .day, value: 6, to: .now) ?? .now, notes: "Keep transitions calm and readable for the whole team.")
        let volunteers = [
            Volunteer(fullName: "Ava Mitchell", role: .worshipLeader),
            Volunteer(fullName: "Noah Brooks", role: .musician),
            Volunteer(fullName: "Grace Patel", role: .vocalist),
            Volunteer(fullName: "Eli Carter", role: .soundEngineer)
        ]

        context.insert(setList)
        songs.enumerated().forEach { index, song in
            context.insert(song)
            context.insert(SetListSong(setListId: setList.id, songId: song.id, order: index, selectedKey: song.originalKey, tempo: song.bpm))
        }
        volunteers.forEach {
            context.insert($0)
            context.insert(VolunteerAssignment(volunteerId: $0.id, serviceDate: setList.serviceDate, role: VolunteerRole(rawValue: $0.role) ?? .musician, confirmed: $0.fullName != "Noah Brooks"))
        }
        context.insert(RehearsalNote(setListId: setList.id, content: "Run the full set once, then isolate transitions into Steady Light."))
        context.insert(SubscriptionState())
        try? context.save()
    }

    func createOnboardingProfile(context: ModelContext, churchName: String, teamSize: Int, worshipStyle: WorshipStyle, role: PrimaryRole, notificationsEnabled: Bool) {
        context.insert(ChurchProfile(churchName: churchName, worshipStyle: worshipStyle, primaryRole: role, teamSize: teamSize, notificationsEnabled: notificationsEnabled))
        if notificationsEnabled {
            Task { _ = await NotificationService().requestAuthorization() }
        }
        try? context.save()
    }

    func createSetList(context: ModelContext, title: String, date: Date, notes: String = "") {
        let setList = SetList(title: title, serviceDate: date, notes: notes)
        context.insert(setList)
        syncEngine.enqueueLocalChange(entityName: "SetList", entityID: setList.id)
        try? context.save()
    }

    func addSong(context: ModelContext, title: String, artist: String, key: String, bpm: Int, category: SongCategory, lyrics: String = "Verse\nAdd lyrics here") {
        let song = Song(title: title, artist: artist, originalKey: key, bpm: bpm, lyrics: lyrics, chordChart: "[\(key)] Add chord chart here", tags: [category.rawValue])
        context.insert(song)
        syncEngine.enqueueLocalChange(entityName: "Song", entityID: song.id)
        try? context.save()
    }

    func assign(song: Song, to setList: SetList, context: ModelContext) {
        let setListID = setList.id
        let descriptor = FetchDescriptor<SetListSong>(predicate: #Predicate { $0.setListId == setListID })
        let count = (try? context.fetch(descriptor).count) ?? 0
        context.insert(SetListSong(setListId: setList.id, songId: song.id, order: count, selectedKey: song.originalKey, tempo: song.bpm))
        try? context.save()
    }

    func generateSuggestions(worshipStyle: String, songs: [Song], notes: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            aiSuggestions = try await aiService.generateSetFlowSuggestions(worshipStyle: worshipStyle, setList: songs, serviceNotes: notes)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func export(setList: SetList, songs: [Song], notes: [RehearsalNote]) {
        do {
            selectedPDFURL = try pdfService.makeSetListPDF(setList: setList, songs: songs, notes: notes)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
