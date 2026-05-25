import SwiftData
import SwiftUI

struct DashboardView: View {
    @Environment(AppViewModel.self) private var appModel
    @Query(sort: \SetList.serviceDate) private var setLists: [SetList]
    @Query private var setListSongs: [SetListSong]
    @Query private var assignments: [VolunteerAssignment]
    @Query private var subscriptions: [SubscriptionState]

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 12)]

    var body: some View {
        ZStack {
            StageBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    if let error = appModel.errorMessage {
                        ErrorBanner(message: error)
                    }
                    UpgradeBanner { appModel.path.append(.paywall) }
                    upcomingServices
                    quickActions
                    operationalStatus
                }
                .padding()
            }
        }
        .navigationTitle("Dashboard")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { appModel.path.append(.settings) } label: {
                    Image(systemName: "gearshape.fill")
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Sunday, simplified.")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(.white)
            Text("Plan sets, sync your team, and keep rehearsal focused.")
                .foregroundStyle(.white.opacity(0.68))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var upcomingServices: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Upcoming Services", subtitle: "Current set lists and service flow")
            if setLists.isEmpty {
                EmptyStateView(title: "No services yet", message: "Create a set list to start planning.", systemImage: "music.note.list")
            } else {
                ForEach(setLists.prefix(3)) { setList in
                    Button {
                        appModel.path.append(.setListBuilder)
                    } label: {
                        SetListCard(setList: setList, songCount: setListSongs.filter { $0.setListId == setList.id }.count)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Quick Actions", subtitle: nil)
            LazyVGrid(columns: columns, spacing: 12) {
                quickAction("Create Set List", "plus.circle.fill", .setListBuilder)
                quickAction("Schedule Volunteers", "person.2.fill", .scheduler)
                quickAction("Open Lyric Prompter", "text.alignleft", .lyricPrompter)
                quickAction("Transpose Song", "music.quarternote.3", .transposer)
                quickAction("Start Rehearsal", "play.circle.fill", .rehearsal)
                quickAction("Add Song", "music.note", .songLibrary)
            }
        }
    }

    private func quickAction(_ title: String, _ icon: String, _ route: AppRoute) -> some View {
        Button {
            appModel.path.append(route)
        } label: {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(WFColor.gold)
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, minHeight: 92)
            .wfPanel()
        }
        .buttonStyle(.plain)
    }

    private var operationalStatus: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Team Flow", subtitle: "Pending confirmations, lyric sync, and subscription")
            HStack {
                Label("\(assignments.filter { !$0.confirmed }.count) pending confirmations", systemImage: "clock.fill")
                Spacer()
            }
            HStack {
                Label("Latest lyric sync: placeholder ready", systemImage: "arrow.triangle.2.circlepath")
                Spacer()
            }
            HStack {
                Label("Plan: \(subscriptions.first?.plan ?? "Free")", systemImage: "crown.fill")
                Spacer()
            }
        }
        .font(.subheadline)
        .foregroundStyle(.white.opacity(0.76))
        .wfPanel()
    }
}
