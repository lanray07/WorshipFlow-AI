import Foundation

enum WatchPlaceholderFeature: String, CaseIterable {
    case rehearsalReminders = "Rehearsal reminders"
    case quickLyricPrompts = "Quick lyric prompts"
    case volunteerAlerts = "Volunteer alerts"
    case countdownTimer = "Countdown timer"
}

struct WatchCompanionPlaceholder {
    var features = WatchPlaceholderFeature.allCases
    var note = "Add a watchOS companion target when live rehearsal prompts are ready."
}
