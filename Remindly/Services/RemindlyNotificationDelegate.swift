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

    // Handle "Stop" action tap and notification tap
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 didReceive response: UNNotificationResponse,
                                 withCompletionHandler completionHandler: @escaping () -> Void) {
        let identifier = response.notification.request.identifier
        let uuidString = identifier.components(separatedBy: "-spam-").first?
                                   .components(separatedBy: "-").prefix(5)
                                   .joined(separator: "-") ?? ""
        let isStopAction = response.actionIdentifier == "STOP_SPAM"

        Task { @MainActor in
            if let context = self.modelContext, let uuid = UUID(uuidString: uuidString) {
                let descriptor = FetchDescriptor<Reminder>(predicate: #Predicate { $0.id == uuid })
                if let reminder = try? context.fetch(descriptor).first {
                    if isStopAction {
                        reminder.isSpamming = false
                        reminder.hasBeenStopped = true
                        NotificationService.shared.cancelNotifications(for: reminder)
                    } else {
                        reminder.isSpamming = true
                        NotificationCenter.default.post(name: .showActiveAlerts, object: nil)
                    }
                    try? context.save()
                }
            }
            completionHandler()
        }
    }
}

extension Notification.Name {
    static let showActiveAlerts = Notification.Name("showActiveAlerts")
}
