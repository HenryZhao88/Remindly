import SwiftUI
import SwiftData
import UserNotifications
import BackgroundTasks

@main
struct RemindlyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var settings = AppSettings()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema(versionedSchema: SchemaV1.self)
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, migrationPlan: RemindlyMigrationPlan.self, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        appDelegate.notificationDelegate.modelContext = sharedModelContainer.mainContext
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
        }
        .modelContainer(sharedModelContainer)
    }
}

// MARK: - AppDelegate

final class AppDelegate: NSObject, UIApplicationDelegate {
    let notificationDelegate = RemindlyNotificationDelegate()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        NotificationService.shared.requestAuthorization { _ in }
        
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
            forTaskWithIdentifier: "com.remindly.app.spamRefresh",
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
                if reminder.shouldStartSpammingNow(using: { now }) {
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
