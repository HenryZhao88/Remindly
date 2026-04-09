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
            options: [.foreground])
        let category = UNNotificationCategory(
            identifier: "HIGH_URGENCY",
            actions: [stopAction],
            intentIdentifiers: [],
            options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        UNUserNotificationCenter.current().delegate = notificationDelegate

        // Register background refresh task
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "com.remindly.app.spamRefresh",
            using: nil) { task in
                self.handleSpamRefresh(task: task as! BGAppRefreshTask)
            }
        return true
    }

    private func handleSpamRefresh(task: BGAppRefreshTask) {
        guard let context = notificationDelegate.modelContext else {
            task.setTaskCompleted(success: false)
            return
        }
        let descriptor = FetchDescriptor<Reminder>(predicate: #Predicate { $0.isSpamming })
        let spamming = (try? context.fetch(descriptor)) ?? []
        for reminder in spamming {
            NotificationService.shared.rescheduleSpamIfNeeded(for: reminder)
            NotificationService.shared.scheduleBackgroundRefresh()
        }
        task.setTaskCompleted(success: true)
    }
}
