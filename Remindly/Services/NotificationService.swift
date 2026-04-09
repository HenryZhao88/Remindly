import UserNotifications
import BackgroundTasks

final class NotificationService {
    static let shared = NotificationService()
    /// Number of 1-second-apart notifications scheduled per spam burst.
    static let spamBurstCount = 60

    private let center: NotificationScheduling

    init(center: NotificationScheduling = UNUserNotificationCenter.current()) {
        self.center = center
    }

    // MARK: - Permissions

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async { completion(granted) }
        }
    }

    // MARK: - Schedule

    func scheduleNotifications(for reminder: Reminder) {
        cancelNotifications(for: reminder) {
            self.doSchedule(reminder)
        }
    }

    private func doSchedule(_ reminder: Reminder) {
        switch reminder.urgency {
        case .none, .low, .meeting:
            for offset in reminder.urgency.leadOffsets {
                addSingleNotification(reminder: reminder, offset: offset)
            }
        case .high:
            addSpamBurst(reminder: reminder, startOffset: 0)
            scheduleBackgroundRefresh()
        case .custom:
            let config = reminder.customConfig
            for offset in config.leadOffsets where offset != 0 {
                addSingleNotification(reminder: reminder, offset: offset)
            }
            if config.spamAtEventTime {
                addSpamBurst(reminder: reminder, startOffset: 0)
                scheduleBackgroundRefresh()
            } else {
                addSingleNotification(reminder: reminder, offset: 0)
            }
        }
    }

    // MARK: - Cancel

    /// `completion` is always dispatched to the main queue.
    func cancelNotifications(for reminder: Reminder, completion: (() -> Void)? = nil) {
        let prefix = reminder.id.uuidString
        center.getPendingNotificationRequests { requests in
            let ids = requests
                .filter { $0.identifier.hasPrefix(prefix) }
                .map { $0.identifier }
            self.center.removePendingNotificationRequests(withIdentifiers: ids)
            self.center.removeDeliveredNotifications(withIdentifiers: ids)
            DispatchQueue.main.async { completion?() }
        }
    }

    // MARK: - Reschedule spam (called when app becomes active and reminder.isSpamming == true)

    func rescheduleSpamIfNeeded(for reminder: Reminder) {
        guard reminder.isSpamming else { return }
        let prefix = reminder.id.uuidString
        center.getPendingNotificationRequests { pending in
            let spamPending = pending.filter {
                $0.identifier.hasPrefix(prefix) && $0.identifier.contains("-spam-")
            }
            if spamPending.count < 10 {
                self.addSpamBurst(reminder: reminder, startOffset: 1 as Int)
            }
        }
    }

    // MARK: - Background refresh scheduling

    /// Override in tests to avoid BGTaskScheduler registration assertions.
    var backgroundRefreshScheduler: (() -> Void)?

    func scheduleBackgroundRefresh() {
        if let override = backgroundRefreshScheduler {
            override()
            return
        }
        let request = BGAppRefreshTaskRequest(identifier: "com.remindly.app.spamRefresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 50)
        try? BGTaskScheduler.shared.submit(request)
    }

    // MARK: - Private helpers

    private func addSingleNotification(reminder: Reminder, offset: TimeInterval) {
        let fireDate = reminder.date.addingTimeInterval(offset)
        guard fireDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.sound = .default
        if offset < 0 {
            let minutes = Int(abs(offset) / 60)
            content.body = "In \(minutes) minute\(minutes == 1 ? "" : "s")"
        }

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let id = "\(reminder.id.uuidString)-\(Int(offset))"
        center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger), withCompletionHandler: nil)
    }

    private func addSpamBurst(reminder: Reminder, startOffset: Int) {
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = "Tap to stop"
        content.sound = .default
        content.categoryIdentifier = "HIGH_URGENCY"

        for i in 0..<Self.spamBurstCount {
            let fireDate = reminder.date.addingTimeInterval(TimeInterval(startOffset) + TimeInterval(i))
            guard fireDate > Date() else { continue }
            let components = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute, .second], from: fireDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let id = "\(reminder.id.uuidString)-spam-\(i)-\(startOffset)"
            center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger), withCompletionHandler: nil)
        }
    }
}
