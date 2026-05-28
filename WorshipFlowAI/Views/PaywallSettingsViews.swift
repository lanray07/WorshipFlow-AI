import SwiftData
import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(SubscriptionService.self) private var subscriptionService

    var body: some View {
        ZStack {
            StageBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    SectionHeader(title: "WorshipFlow AI Pro", subtitle: "Unlock the complete worship team operating system")

                    freePlan

                    if subscriptionService.isLoading {
                        ProgressView("Loading StoreKit products...")
                            .foregroundStyle(.white)
                    }

                    if let message = subscriptionService.errorMessage {
                        ErrorBanner(message: message)
                    }

                    if subscriptionService.products.isEmpty {
                        ForEach(SubscriptionService.fallbackOffers) { offer in
                            fallbackPlan(offer)
                        }
                    } else {
                        ForEach(subscriptionService.products) { product in
                            productPlan(product)
                        }
                    }

                    restoreAndLegal
                }
                .padding()
            }
        }
        .navigationTitle("Upgrade")
        .task { await subscriptionService.loadProducts() }
    }

    private var freePlan: some View {
        planShell(
            title: "Free",
            price: "GBP 0",
            duration: "No subscription required",
            features: ["3 set lists/month", "Basic song library", "Limited scheduling", "WorshipFlow AI branding"]
        ) {
            Text("Current starter plan")
                .font(.callout.weight(.semibold))
                .foregroundStyle(.white.opacity(0.7))
        }
    }

    private func productPlan(_ product: Product) -> some View {
        let offer = SubscriptionService.fallbackOffers.first { $0.id == product.id }

        return planShell(
            title: product.displayName,
            price: product.displayPrice,
            duration: offer?.duration ?? subscriptionDuration(for: product),
            features: offer?.features ?? ["Unlock WorshipFlow AI premium planning tools"]
        ) {
            Button {
                Task { await subscriptionService.purchase(product) }
            } label: {
                if subscriptionService.isPurchasingProductID == product.id {
                    ProgressView()
                        .tint(.black)
                } else {
                    Text("Subscribe")
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(WFColor.gold)
            .disabled(subscriptionService.isPurchasingProductID != nil)
        }
    }

    private func fallbackPlan(_ offer: SubscriptionService.FallbackOffer) -> some View {
        planShell(title: offer.title, price: offer.price, duration: offer.duration, features: offer.features) {
            Button {
                Task { await subscriptionService.loadProducts() }
            } label: {
                Text("Load Subscription")
            }
            .buttonStyle(.borderedProminent)
            .tint(WFColor.gold)
        }
    }

    private func planShell<CTA: View>(
        title: String,
        price: String,
        duration: String,
        features: [String],
        @ViewBuilder cta: () -> CTA
    ) -> some View {
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

            Text(duration)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.72))

            ForEach(features, id: \.self) { feature in
                Label(feature, systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.white.opacity(0.78))
            }

            cta()
        }
        .wfPanel()
    }

    private var restoreAndLegal: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                Task { await subscriptionService.restorePurchases() }
            } label: {
                Label("Restore Purchases", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.bordered)
            .tint(WFColor.softGold)

            Text("Subscriptions renew automatically unless cancelled at least 24 hours before the end of the current period. Payment is charged to your Apple ID. You can manage or cancel subscriptions in your App Store account settings.")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.68))

            HStack(spacing: 14) {
                Link("Privacy Policy", destination: URL(string: "https://github.com/lanray07/WorshipFlow-AI/blob/main/PRIVACY.md")!)
                Link("Terms of Use (EULA)", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
            }
            .font(.footnote.weight(.semibold))
            .foregroundStyle(WFColor.gold)
        }
        .wfPanel()
    }

    private func subscriptionDuration(for product: Product) -> String {
        guard let subscription = product.subscription else {
            return "Auto-renewable subscription"
        }

        let unit: String
        switch subscription.subscriptionPeriod.unit {
        case .day:
            unit = subscription.subscriptionPeriod.value == 1 ? "day" : "days"
        case .week:
            unit = subscription.subscriptionPeriod.value == 1 ? "week" : "weeks"
        case .month:
            unit = subscription.subscriptionPeriod.value == 1 ? "month" : "months"
        case .year:
            unit = subscription.subscriptionPeriod.value == 1 ? "year" : "years"
        @unknown default:
            unit = "period"
        }

        return "\(subscription.subscriptionPeriod.value) \(unit), auto-renewing"
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
                    Link(destination: URL(string: "https://github.com/lanray07/WorshipFlow-AI/blob/main/PRIVACY.md")!) {
                        Label("Privacy policy", systemImage: "lock.fill")
                    }
                    Link(destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!) {
                        Label("Terms of use", systemImage: "doc.text.fill")
                    }
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
