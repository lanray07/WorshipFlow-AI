import SwiftData
import SwiftUI

struct SongLibraryView: View {
    @Environment(AppViewModel.self) private var appModel
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Song.title) private var songs: [Song]
    @State private var title = ""
    @State private var artist = ""
    @State private var key = "G"
    @State private var bpm = 90
    @State private var category = SongCategory.worship
    @State private var lyrics = ""

    var body: some View {
        ZStack {
            StageBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    addSongPanel
                    SectionHeader(title: "Song Library", subtitle: "Lyrics, chord charts, capo notes, tags, and categories")
                    if songs.isEmpty {
                        EmptyStateView(title: "No songs", message: "Add songs to prepare set lists and chord charts.", systemImage: "music.note")
                    } else {
                        ForEach(songs) { song in
                            VStack(alignment: .leading, spacing: 12) {
                                SongCard(song: song)
                                ChordChartView(chart: song.chordChart)
                                    .frame(height: 120)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Song Library")
    }

    private var addSongPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Add Song", subtitle: nil)
            TextField("Song title", text: $title).textFieldStyle(.roundedBorder)
            VoiceInputButton(text: $title, prompt: "Dictate Song Title")
            TextField("Artist", text: $artist).textFieldStyle(.roundedBorder)
            HStack {
                TextField("Key", text: $key).textFieldStyle(.roundedBorder)
                Stepper("BPM \(bpm)", value: $bpm, in: 40...220)
                    .foregroundStyle(.white)
            }
            Picker("Category", selection: $category) {
                ForEach(SongCategory.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.menu)
            TextEditor(text: $lyrics)
                .frame(minHeight: 110)
                .scrollContentBackground(.hidden)
                .padding(8)
                .background(Color.black.opacity(0.22), in: RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(WFColor.stroke))
                .foregroundStyle(.white)
            VoiceInputButton(text: $lyrics, prompt: "Dictate Lyrics or Notes", appendMode: true)
            Button("Save Song") {
                appModel.addSong(context: modelContext, title: title.isEmpty ? "Untitled Song" : title, artist: artist.isEmpty ? "Unknown" : artist, key: key, bpm: bpm, category: category, lyrics: lyrics.isEmpty ? "Verse\nAdd lyrics here" : lyrics)
                title = ""
                artist = ""
                lyrics = ""
            }
            .buttonStyle(.borderedProminent)
            .tint(WFColor.gold)
        }
        .wfPanel()
    }
}
