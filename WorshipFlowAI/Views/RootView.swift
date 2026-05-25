import SwiftData
import SwiftUI

struct RootView: View {
    @Environment(AppViewModel.self) private var appModel
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [ChurchProfile]

    var body: some View {
        @Bindable var appModel = appModel
        NavigationStack(path: $appModel.path) {
            Group {
                if profiles.isEmpty {
                    OnboardingView()
                } else {
                    DashboardView()
                }
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .setListBuilder: SetListBuilderView()
                case .songLibrary: SongLibraryView()
                case .transposer: TransposerView()
                case .lyricPrompter: LyricPrompterScreen()
                case .scheduler: VolunteerSchedulerView()
                case .rehearsal: RehearsalModeView()
                case .serviceTimeline: ServiceTimelineView()
                case .messaging: TeamMessagingPlaceholderView()
                case .analytics: AnalyticsDashboardView()
                case .exports: PDFExportView()
                case .paywall: PaywallView()
                case .settings: SettingsView()
                }
            }
        }
        .tint(WFColor.gold)
        .task {
            appModel.seedIfNeeded(context: modelContext)
        }
    }
}
