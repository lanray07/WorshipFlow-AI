import Foundation
import UserNotifications

struct NotificationService {
    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    func scheduleRehearsalReminder(title: String, date: Date) async throws {
        let content = UNMutableNotificationContent()
        content.title = "WorshipFlow Rehearsal"
        content.body = title
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        try await UNUserNotificationCenter.current().add(request)
    }
}
