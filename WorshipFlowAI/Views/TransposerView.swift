import SwiftData
import SwiftUI

struct TransposerView: View {
    @Query(sort: \Song.title) private var songs: [Song]
    @State private var selectedSongID: UUID?
    @State private var semitones = 0
    @State private var vocalistRange = "Medium"

    var body: some View {
        ZStack {
            StageBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    SectionHeader(title: "Song Key Transposer", subtitle: "Transpose chords, save alternate keys, and estimate comfort")
                    Picker("Song", selection: $selectedSongID) {
                        Text("Choose a song").tag(Optional<UUID>.none)
                        ForEach(songs) { song in
                            Text(song.title).tag(Optional(song.id))
                        }
                    }
                    .pickerStyle(.menu)
                    .wfPanel()

                    if let song = songs.first(where: { $0.id == selectedSongID }) ?? songs.first {
                        controls(song)
                        ChordChartView(chart: transpose(chart: song.chordChart, semitones: semitones))
                            .frame(minHeight: 260)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Transposer")
    }

    private func controls(_ song: Song) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Stepper("Transpose: \(semitones) semitones", value: $semitones, in: -6...6)
            Picker("Vocalist range", selection: $vocalistRange) {
                Text("Low").tag("Low")
                Text("Medium").tag("Medium")
                Text("High").tag("High")
            }
            .pickerStyle(.segmented)
            ReportPreviewView(title: "Generated Support", lines: [
                "Original key: \(song.originalKey)",
                "Capo suggestion: Capo \(max(0, semitones)) placeholder",
                "Vocalist comfort estimate: \(vocalistRange) range should review bridge and final chorus",
                "Simplify chords: placeholder ready"
            ])
        }
        .foregroundStyle(.white)
        .wfPanel()
    }

    private func transpose(chart: String, semitones: Int) -> String {
        let notes = ["C", "C#", "D", "Eb", "E", "F", "F#", "G", "Ab", "A", "Bb", "B"]
        var output = chart
        for note in notes.sorted(by: { $0.count > $1.count }) {
            guard let index = notes.firstIndex(of: note) else { continue }
            let target = notes[(index + semitones + notes.count * 4) % notes.count]
            output = output.replacingOccurrences(of: "[\(note)", with: "[\(target)")
        }
        return output
    }
}
