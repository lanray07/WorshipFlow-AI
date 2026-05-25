import SwiftData
import SwiftUI

@main
struct WorshipFlowAIApp: App {
    @State private var appModel = AppViewModel()
    @State private var subscriptionService = SubscriptionService()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appModel)
                .environment(subscriptionService)
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: [
            ChurchProfile.self,
            Song.self,
            SetList.self,
            SetListSong.self,
            Volunteer.self,
            VolunteerAssignment.self,
            RehearsalNote.self,
            SubscriptionState.self
        ])
    }
}
