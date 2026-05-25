import SwiftData
import SwiftUI

struct LyricPrompterScreen: View {
    @Query(sort: \Song.title) private var songs: [Song]
    @State private var selectedSongID: UUID?
    @State private var fontSize = 34.0
    @State private var scrollSpeed = 0.4
    @State private var rehearsalMode = true

    var body: some View {
        ZStack {
            StageBackground()
            VStack(spacing: 14) {
                controls
                if let song = songs.first(where: { $0.id == selectedSongID }) ?? songs.first {
                    LyricPrompterView(lyrics: song.lyrics, fontSize: fontSize, highlightedSection: "Current: Chorus · Next: Bridge")
                    cuePanel(song)
                } else {
                    EmptyStateView(title: "No lyrics", message: "Add a song to use stage mode.", systemImage: "text.alignleft")
                }
            }
            .padding()
        }
        .navigationTitle("Lyric Prompter")
    }

    private var controls: some View {
        VStack(spacing: 10) {
            Picker("Song", selection: $selectedSongID) {
                Text("Choose a song").tag(Optional<UUID>.none)
                ForEach(songs) { song in
                    Text(song.title).tag(Optional(song.id))
                }
            }
            Slider(value: $fontSize, in: 24...72) { Text("Font size") }
            Slider(value: $scrollSpeed, in: 0...1) { Text("Auto-scroll speed") }
            Toggle("Rehearsal mode", isOn: $rehearsalMode)
        }
        .foregroundStyle(.white)
        .wfPanel()
    }

    private func cuePanel(_ song: Song) -> some View {
        HStack {
            Label("Cue: lead vocal watches final line", systemImage: "waveform")
            Spacer()
            Text("Sync placeholder")
                .foregroundStyle(WFColor.gold)
        }
        .font(.footnote.weight(.medium))
        .foregroundStyle(.white.opacity(0.76))
        .wfPanel()
    }
}
