import Foundation

enum WorshipFlowWidgetKind: String, CaseIterable {
    case upcomingService
    case todaysRehearsal
    case volunteerReminder
    case currentSetList
}

struct WidgetPlaceholderPlan {
    var supportedWidgets = WorshipFlowWidgetKind.allCases
    var note = "Add a WidgetKit extension target and reuse SwiftData snapshots for timeline entries."
}
