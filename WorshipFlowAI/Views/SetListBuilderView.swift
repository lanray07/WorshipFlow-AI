import SwiftData
import SwiftUI

struct SetListBuilderView: View {
    @Environment(AppViewModel.self) private var appModel
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SetList.serviceDate) private var setLists: [SetList]
    @Query(sort: \Song.title) private var songs: [Song]
    @Query(sort: \SetListSong.order) private var setListSongs: [SetListSong]
    @State private var title = "New Worship Set"
    @State private var date = Date()
    @State private var serviceNotes = ""

    var body: some View {
        ZStack {
            StageBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    createPanel
                    if let current = setLists.first {
                        currentSet(current)
                    }
                    aiPanel
                }
                .padding()
            }
        }
        .navigationTitle("Set List Builder")
    }

    private var createPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Create Worship Set", subtitle: "Build reusable service templates and flow notes")
            TextField("Set list title", text: $title)
                .textFieldStyle(.roundedBorder)
            VoiceInputButton(text: $title, prompt: "Dictate Set Title")
            DatePicker("Service date", selection: $date)
                .foregroundStyle(.white)
            TextEditor(text: $serviceNotes)
                .frame(minHeight: 96)
                .scrollContentBackground(.hidden)
                .padding(8)
                .background(Color.black.opacity(0.22), in: RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(WFColor.stroke))
                .foregroundStyle(.white)
            VoiceInputButton(text: $serviceNotes, prompt: "Dictate Flow Notes", appendMode: true)
            Button {
                appModel.createSetList(context: modelContext, title: title, date: date, notes: serviceNotes)
            } label: {
                Label("Create Set List", systemImage: "plus.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(WFColor.gold)
        }
        .wfPanel()
    }

    private func currentSet(_ setList: SetList) -> some View {
        let rows = setListSongs.filter { $0.setListId == setList.id }.sorted { $0.order < $1.order }
        let selectedSongs = rows.compactMap { row in songs.first { $0.id == row.songId } }
        return VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: setList.title, subtitle: "Drag-and-drop ordering placeholder with saved templates and duplicate set workflow")
            ForEach(Array(selectedSongs.enumerated()), id: \.element.id) { index, song in
                HStack {
                    Text("\(index + 1)")
                        .font(.headline)
                        .foregroundStyle(WFColor.gold)
                    SongCard(song: song)
                }
            }
            Menu {
                ForEach(songs) { song in
                    Button(song.title) { appModel.assign(song: song, to: setList, context: modelContext) }
                }
            } label: {
                Label("Add Song to Set", systemImage: "music.note")
            }
            .buttonStyle(.bordered)
            .tint(WFColor.gold)
            HStack {
                Button("Save Template") {}
                Button("Duplicate Set") { appModel.createSetList(context: modelContext, title: "\(setList.title) Copy", date: setList.serviceDate) }
                Button("Rehearsal Mode") { appModel.path.append(.rehearsal) }
            }
            .buttonStyle(.bordered)
            .tint(WFColor.gold)
        }
    }

    private var aiPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "AI Flow Suggestions", subtitle: "Optional recommendations for transitions, keys, energy, openings, and closings")
            if appModel.isLoading {
                ProgressView("Generating suggestions...")
            } else if let suggestions = appModel.aiSuggestions {
                ReportPreviewView(title: suggestions.summary, lines: suggestions.flowSuggestions + suggestions.transitionNotes + suggestions.recommendedKeys)
            }
            Button {
                Task { await appModel.generateSuggestions(worshipStyle: "Mixed", songs: songs, notes: serviceNotes.isEmpty ? (setLists.first?.notes ?? "") : serviceNotes) }
            } label: {
                Label("Generate Mock AI Suggestions", systemImage: "sparkles")
            }
            .buttonStyle(.borderedProminent)
            .tint(WFColor.gold)
            Text(WorshipFlowAIPrompt.disclaimer)
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.62))
        }
        .wfPanel()
    }
}
