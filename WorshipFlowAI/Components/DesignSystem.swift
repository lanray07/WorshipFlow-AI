import SwiftUI

enum WFColor {
    static let midnight = Color(red: 0.03, green: 0.06, blue: 0.12)
    static let deepBlue = Color(red: 0.06, green: 0.16, blue: 0.34)
    static let gold = Color(red: 0.94, green: 0.72, blue: 0.32)
    static let softGold = Color(red: 1.0, green: 0.86, blue: 0.55)
    static let ink = Color(red: 0.10, green: 0.13, blue: 0.18)
    static let panel = Color.white.opacity(0.075)
    static let stroke = Color.white.opacity(0.12)
}

struct StageBackground: View {
    var body: some View {
        LinearGradient(
            colors: [WFColor.midnight, WFColor.deepBlue, WFColor.ink],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct PanelModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(WFColor.panel, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(WFColor.stroke))
    }
}

extension View {
    func wfPanel() -> some View {
        modifier(PanelModifier())
    }
}

struct SectionHeader: View {
    var title: String
    var subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.68))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct EmptyStateView: View {
    var title: String
    var message: String
    var systemImage: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(WFColor.gold)
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.66))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .wfPanel()
    }
}

struct ErrorBanner: View {
    var message: String

    var body: some View {
        Label(message, systemImage: "exclamationmark.triangle.fill")
            .font(.footnote.weight(.medium))
            .foregroundStyle(.white)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.red.opacity(0.24), in: RoundedRectangle(cornerRadius: 8))
    }
}
