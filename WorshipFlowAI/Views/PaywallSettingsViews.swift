import SwiftData
import SwiftUI

struct PaywallView: View {
    @Environment(SubscriptionService.self) private var subscriptionService

    var body: some View {
        ZStack {
            StageBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    SectionHeader(title: "WorshipFlow AI Pro", subtitle: "Unlock the complete worship team operating system")
                    plan("Free", price: "£0", features: ["3 set lists/month", "Basic song library", "Limited scheduling", "WorshipFlow AI branding"])
                    plan("Pro", price: "£9.99/mo or £79.99/yr", features: ["Unlimited set lists", "Lyric prompter", "Key transposer", "Volunteer scheduling", "PDF exports", "AI worship flow suggestions"])
                    plan("Church Plan", price: "£29.99/mo", features: ["Multiple worship teams", "Advanced scheduling", "Team collaboration placeholder", "Admin controls placeholder", "Cloud sync placeholder"])
                    if subscriptionService.isLoading {
                        ProgressView("Loading StoreKit products...")
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Upgrade")
        .task { await subscriptionService.loadProducts() }
    }

    private func plan(_ title: String, price: String, features: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                Spacer()
                Text(price)
                    .font(.headline)
                    .foregroundStyle(WFColor.gold)
            }
            ForEach(features, id: \.self) { feature in
                Label(feature, systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.white.opacity(0.78))
            }
            Button("Choose \(title)") {}
                .buttonStyle(.borderedProminent)
                .tint(WFColor.gold)
        }
        .wfPanel()
    }
}

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [ChurchProfile]
    @State private var fontSize = 34.0
    @State private var reminders = true

    var body: some View {
        ZStack {
            StageBackground()
            List {
                Section("Subscription") {
                    Label("Manage subscription", systemImage: "crown.fill")
                }
                Section("Worship Preferences") {
                    Text(profiles.first?.worshipStyle ?? "Mixed")
                    Toggle("Reminder settings", isOn: $reminders)
                    Slider(value: $fontSize, in: 24...72) { Text("Prompter font size") }
                }
                Section("Data") {
                    Label("Export data", systemImage: "square.and.arrow.up")
                    Label("Privacy policy", systemImage: "lock.fill")
                    Label("Terms of use", systemImage: "doc.text.fill")
                    Button(role: .destructive) {
                        deleteAllData()
                    } label: {
                        Label("Delete all data", systemImage: "trash.fill")
                    }
                }
                Section("Placeholders") {
                    Text(WidgetPlaceholderPlan().note)
                    Text(WatchCompanionPlaceholder().note)
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Settings")
    }

    private func deleteAllData() {
        try? modelContext.delete(model: ChurchProfile.self)
        try? modelContext.delete(model: Song.self)
        try? modelContext.delete(model: SetList.self)
        try? modelContext.delete(model: SetListSong.self)
        try? modelContext.delete(model: Volunteer.self)
        try? modelContext.delete(model: VolunteerAssignment.self)
        try? modelContext.delete(model: RehearsalNote.self)
        try? modelContext.delete(model: SubscriptionState.self)
    }
}
