import SwiftUI
import SwiftData
import UserNotifications
import BackgroundTasks

@main
struct RemindlyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var settings = AppSettings()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
        }
        .modelContainer(for: Reminder.self) { result in
            if case .success(let container) = result {
                appDelegate.notificationDelegate.modelContext = container.mainContext
            }
        }
    }
}

// MARK: - AppDelegate

final class AppDelegate: NSObject, UIApplicationDelegate {
    let notificationDelegate = RemindlyNotificationDelegate()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Register notification category with Stop action for high-urgency spam
        let stopAction = UNNotificationAction(
            identifier: "STOP_SPAM",
            title: "Stop",
            options: [.destructive])
        let category = UNNotificationCategory(
            identifier: "HIGH_URGENCY",
            actions: [stopAction],
            intentIdentifiers: [],
            options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        UNUserNotificationCenter.current().delegate = notificationDelegate

        // Register background refresh task
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "com.henremindlyry.app.spamRefresh",
            using: nil) { task in
                self.handleSpamRefresh(task: task as! BGAppRefreshTask)
            }
        return true
    }

    private func handleSpamRefresh(task: BGAppRefreshTask) {
        Task { @MainActor in
            guard let context = self.notificationDelegate.modelContext else {
                task.setTaskCompleted(success: false)
                return
            }
            let now = Date()
            let descriptor = FetchDescriptor<Reminder>()
            let allReminders = (try? context.fetch(descriptor)) ?? []

            var scheduledAny = false
            for reminder in allReminders {
                let needsSpam = reminder.urgency == .high || (reminder.urgency == .custom && reminder.customConfig.spamAtEventTime)
                if needsSpam && reminder.date <= now && !reminder.hasBeenStopped {
                    // Bug 5 fix: auto-expire spam after maxSpamDuration
                    if now.timeIntervalSince(reminder.date) > NotificationService.maxSpamDuration {
                        reminder.isSpamming = false
                        reminder.hasBeenStopped = true
                        continue
                    }
                    reminder.isSpamming = true
                    NotificationService.shared.rescheduleSpamIfNeeded(for: reminder)
                    scheduledAny = true
                }
            }
            if scheduledAny {
                NotificationService.shared.scheduleBackgroundRefresh()
            }
            task.setTaskCompleted(success: true)
        }
    }
}
