import UserNotifications
import SwiftData

final class RemindlyNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    /// Injected after the app's model container is available.
    var modelContext: ModelContext?

    // Show notifications even when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 willPresent notification: UNNotification,
                                 withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }

    // Handle "Stop" action tap and notification tap (both open Active Alerts)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 didReceive response: UNNotificationResponse,
                                 withCompletionHandler completionHandler: @escaping () -> Void) {
        let identifier = response.notification.request.identifier
        // Extract reminder UUID prefix (first 5 UUID components before any "-spam-" or offset suffix)
        let uuidString = identifier.components(separatedBy: "-spam-").first?
                                   .components(separatedBy: "-").prefix(5)
                                   .joined(separator: "-") ?? ""

        if let context = modelContext, let uuid = UUID(uuidString: uuidString) {
            markReminderSpamming(uuid: uuid, context: context)
        }

        NotificationCenter.default.post(name: .showActiveAlerts, object: nil)
        completionHandler()
    }

    private func markReminderSpamming(uuid: UUID, context: ModelContext) {
        let descriptor = FetchDescriptor<Reminder>(predicate: #Predicate { $0.id == uuid })
        guard let reminder = try? context.fetch(descriptor).first else { return }
        reminder.isSpamming = true
        try? context.save()
    }
}

extension Notification.Name {
    static let showActiveAlerts = Notification.Name("showActiveAlerts")
}
