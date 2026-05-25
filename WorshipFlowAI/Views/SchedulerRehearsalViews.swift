import SwiftData
import SwiftUI

struct VolunteerSchedulerView: View {
    @Query(sort: \Volunteer.fullName) private var volunteers: [Volunteer]
    @Query private var assignments: [VolunteerAssignment]

    var body: some View {
        ZStack {
            StageBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    SectionHeader(title: "Volunteer Scheduler", subtitle: "Rotations, availability, recurring schedules, reminders, and absence placeholder")
                    ForEach(volunteers) { volunteer in
                        let assignment = assignments.first { $0.volunteerId == volunteer.id }
                        VolunteerCard(volunteer: volunteer, confirmed: assignment?.confirmed)
                    }
                    ReportPreviewView(title: "Scheduling Tools", lines: [
                        "Rotating schedules: placeholder",
                        "Availability tracking: local field ready",
                        "Role assignments: active",
                        "Livestream team: placeholder",
                        "Emergency replacements: messaging placeholder"
                    ])
                }
                .padding()
            }
        }
        .navigationTitle("Scheduler")
    }
}

struct RehearsalModeView: View {
    @Environment(AppViewModel.self) private var appModel
    @Query(sort: \SetList.serviceDate) private var setLists: [SetList]
    @Query(sort: \Song.title) private var songs: [Song]
    @Query(sort: \SetListSong.order) private var setListSongs: [SetListSong]
    @Query private var notes: [RehearsalNote]

    var body: some View {
        ZStack {
            StageBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    SectionHeader(title: "Rehearsal Mode", subtitle: "Set order, tempo, cue prompts, transitions, and checklist")
                    if let setList = setLists.first {
                        let rows = setListSongs.filter { $0.setListId == setList.id }.sorted { $0.order < $1.order }
                        ForEach(rows) { row in
                            if let song = songs.first(where: { $0.id == row.songId }) {
                                VStack(alignment: .leading, spacing: 8) {
                                    SongCard(song: song)
                                    Text("Tempo \(row.tempo) BPM · Key \(row.selectedKey)")
                                    Text(row.transitionNotes.isEmpty ? "Transition prompt: confirm ending and count-in." : row.transitionNotes)
                                }
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.72))
                            }
                        }
                        ReportPreviewView(title: "Checklist", lines: [
                            "Line check complete",
                            "Transitions rehearsed",
                            "Projection lyric repeats confirmed",
                            "Sound team cue sheet reviewed",
                            "Prayer and scripture placeholders reviewed"
                        ])
                        Button {
                            appModel.export(setList: setList, songs: songs, notes: notes)
                            appModel.path.append(.exports)
                        } label: {
                            Label("Export Rehearsal Notes", systemImage: "square.and.arrow.up")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(WFColor.gold)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Rehearsal")
    }
}

struct ServiceTimelineView: View {
    private var items: [ServiceTimelineItem] {
        let base = Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: .now) ?? .now
        return [
            ServiceTimelineItem(time: base.addingTimeInterval(-900), title: "Countdown", detail: "Team in place, house music ready"),
            ServiceTimelineItem(time: base, title: "Worship Start", detail: "Opening song and welcome transition"),
            ServiceTimelineItem(time: base.addingTimeInterval(1200), title: "Announcements", detail: "Placeholder block"),
            ServiceTimelineItem(time: base.addingTimeInterval(1800), title: "Prayer Moment", detail: "Placeholder block"),
            ServiceTimelineItem(time: base.addingTimeInterval(2400), title: "Sermon", detail: "Placeholder block"),
            ServiceTimelineItem(time: base.addingTimeInterval(4800), title: "Closing Song", detail: "Final worship response")
        ]
    }

    var body: some View {
        ZStack {
            StageBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    SectionHeader(title: "Service Timeline", subtitle: "Countdown, worship, announcements, prayer, sermon, and closing")
                    ForEach(items) { ServiceTimelineCard(item: $0) }
                }
                .padding()
            }
        }
        .navigationTitle("Timeline")
    }
}

struct TeamMessagingPlaceholderView: View {
    var body: some View {
        ZStack {
            StageBackground()
            VStack(alignment: .leading, spacing: 18) {
                SectionHeader(title: "Team Messaging", subtitle: "Architecture placeholder")
                ReportPreviewView(title: "Messaging Modules", lines: [
                    "Rehearsal reminders",
                    "Schedule updates",
                    "Emergency replacements",
                    "Service updates"
                ])
                Text("Messaging is intentionally a placeholder until a secure team backend and consent model are configured.")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.66))
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Messaging")
    }
}
