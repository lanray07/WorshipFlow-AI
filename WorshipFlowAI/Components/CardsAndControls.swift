import SwiftUI

struct SetListCard: View {
    var setList: SetList
    var songCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(setList.title)
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text(setList.serviceDate, style: .date)
                        .foregroundStyle(.white.opacity(0.65))
                }
                Spacer()
                Text("\(songCount) songs")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(WFColor.ink)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(WFColor.gold, in: Capsule())
            }
            Text(setList.notes.isEmpty ? "No flow notes yet" : setList.notes)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
                .lineLimit(2)
        }
        .wfPanel()
    }
}

struct SongCard: View {
    var song: Song

    var body: some View {
        HStack(spacing: 14) {
            VStack {
                Text(song.originalKey)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(WFColor.gold)
                Text("\(song.bpm)")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }
            .frame(width: 52, height: 52)
            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(song.title)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text(song.artist)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.65))
                if !song.tags.isEmpty {
                    Text(song.tags.joined(separator: " · "))
                        .font(.caption)
                        .foregroundStyle(WFColor.softGold)
                }
            }
            Spacer()
        }
        .wfPanel()
    }
}

struct ChordChartView: View {
    var chart: String

    var body: some View {
        ScrollView {
            Text(chart)
                .font(.system(.body, design: .monospaced))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .background(Color.black.opacity(0.28), in: RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(WFColor.stroke))
    }
}

struct LyricPrompterView: View {
    var lyrics: String
    var fontSize: Double
    var highlightedSection: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text(highlightedSection)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(WFColor.gold)
                    .textCase(.uppercase)
                Text(lyrics)
                    .font(.system(size: fontSize, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineSpacing(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(24)
        }
        .background(Color.black.opacity(0.72), in: RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(WFColor.gold.opacity(0.28)))
    }
}

struct VolunteerCard: View {
    var volunteer: Volunteer
    var confirmed: Bool?

    var body: some View {
        HStack {
            Image(systemName: "person.crop.circle.fill")
                .font(.title2)
                .foregroundStyle(WFColor.gold)
            VStack(alignment: .leading, spacing: 3) {
                Text(volunteer.fullName)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text("\(volunteer.role) · \(volunteer.availability)")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.66))
            }
            Spacer()
            if let confirmed {
                Image(systemName: confirmed ? "checkmark.circle.fill" : "clock.fill")
                    .foregroundStyle(confirmed ? .green : WFColor.softGold)
            }
        }
        .wfPanel()
    }
}

struct ServiceTimelineCard: View {
    var item: ServiceTimelineItem

    var body: some View {
        HStack(spacing: 14) {
            Text(item.time, style: .time)
                .font(.caption.weight(.bold))
                .foregroundStyle(WFColor.gold)
                .frame(width: 68, alignment: .leading)
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .foregroundStyle(.white)
                    .font(.headline)
                Text(item.detail)
                    .foregroundStyle(.white.opacity(0.65))
                    .font(.subheadline)
            }
            Spacer()
        }
        .wfPanel()
    }
}

struct AnalyticsChartCard<Content: View>: View {
    var title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
            content
                .frame(height: 180)
        }
        .wfPanel()
    }
}

struct ReportPreviewView: View {
    var title: String
    var lines: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
            ForEach(lines, id: \.self) { line in
                Text(line)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.72))
            }
        }
        .wfPanel()
    }
}

struct UpgradeBanner: View {
    var action: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles")
                .foregroundStyle(WFColor.gold)
            VStack(alignment: .leading, spacing: 2) {
                Text("Unlock WorshipFlow Pro")
                    .font(.headline)
                    .foregroundStyle(.white)
                Text("Prompter, transposer, PDF exports, AI flow suggestions.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.65))
            }
            Spacer()
            Button("Upgrade", action: action)
                .buttonStyle(.borderedProminent)
                .tint(WFColor.gold)
        }
        .wfPanel()
    }
}
