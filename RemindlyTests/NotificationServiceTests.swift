import XCTest
import UserNotifications
@testable import Remindly

// MARK: - Mock

final class MockNotificationCenter: NotificationScheduling {
    var addedRequests: [UNNotificationRequest] = []
    var removedPrefixes: [String] = []
    var authorizationGranted = true

    func add(_ request: UNNotificationRequest, withCompletionHandler: ((Error?) -> Void)?) {
        addedRequests.append(request)
        withCompletionHandler?(nil)
    }

    func removePendingNotificationRequests(withIdentifiers ids: [String]) {
        removedPrefixes.append(contentsOf: ids)
    }

    func removeDeliveredNotifications(withIdentifiers ids: [String]) {}

    func getPendingNotificationRequests(completionHandler: @escaping ([UNNotificationRequest]) -> Void) {
        completionHandler(addedRequests)
    }

    func requestAuthorization(options: UNAuthorizationOptions, completionHandler: @escaping (Bool, Error?) -> Void) {
        completionHandler(authorizationGranted, nil)
    }
}

// MARK: - Tests

final class NotificationServiceTests: XCTestCase {
    var mock: MockNotificationCenter!
    var service: NotificationService!
    var stubbedDate = Date(timeIntervalSince1970: 100000)

    override func setUp() {
        super.setUp()
        mock = MockNotificationCenter()
        service = NotificationService(center: mock, clock: { [weak self] in self?.stubbedDate ?? Date() })
        // Disable BGTaskScheduler in tests to avoid unregistered-identifier assertion.
        service.backgroundRefreshScheduler = {}
    }

    // 7200s ensures the low-urgency -3600s offset resolves to a future date with safe margin during tests
    func makeReminder(urgency: UrgencyLevel, secondsFromNow: TimeInterval = 7200) -> Reminder {
        Reminder(title: "Test", date: stubbedDate.addingTimeInterval(secondsFromNow), urgency: urgency)
    }

    func test_none_schedules_one_notification() {
        let reminder = makeReminder(urgency: .none)
        let exp = expectation(description: "scheduled")
        service.scheduleNotifications(for: reminder) {
            XCTAssertEqual(self.mock.addedRequests.count, 1)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }

    func test_low_schedules_two_notifications() {
        let reminder = makeReminder(urgency: .low)
        let exp = expectation(description: "scheduled")
        service.scheduleNotifications(for: reminder) {
            XCTAssertEqual(self.mock.addedRequests.count, 2)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }

    func test_meeting_schedules_three_notifications() {
        let reminder = makeReminder(urgency: .meeting)
        let exp = expectation(description: "scheduled")
        service.scheduleNotifications(for: reminder) {
            XCTAssertEqual(self.mock.addedRequests.count, 3)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }

    func test_high_schedules_spam_burst() {
        let reminder = makeReminder(urgency: .high)
        let exp = expectation(description: "scheduled")
        service.scheduleNotifications(for: reminder) {
            XCTAssertEqual(self.mock.addedRequests.count, NotificationService.spamBurstCount)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }

    func test_notification_identifiers_use_reminder_id_as_prefix() {
        let reminder = makeReminder(urgency: .none)
        let exp = expectation(description: "scheduled")
        service.scheduleNotifications(for: reminder) {
            XCTAssertTrue(self.mock.addedRequests.allSatisfy {
                $0.identifier.hasPrefix(reminder.id.uuidString)
            })
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }

    func test_cancel_removes_pending_by_prefix() {
        let reminder = makeReminder(urgency: .none)
        let expSchedule = expectation(description: "scheduled")
        service.scheduleNotifications(for: reminder) {
            expSchedule.fulfill()
        }
        wait(for: [expSchedule], timeout: 1)

        let expCancel = expectation(description: "cancelled")
        service.cancelNotifications(for: reminder) {
            let removed = self.mock.removedPrefixes
            XCTAssertTrue(removed.contains(where: { $0.hasPrefix(reminder.id.uuidString) }))
            expCancel.fulfill()
        }
        wait(for: [expCancel], timeout: 1)
    }

    func test_custom_with_15min_schedules_two_notifications() {
        let reminder = makeReminder(urgency: .custom)
        var config = CustomUrgencyConfig()
        config.notify15min = true
        reminder.customConfig = config
        let exp = expectation(description: "scheduled")
        service.scheduleNotifications(for: reminder) {
            XCTAssertEqual(self.mock.addedRequests.count, 2)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }

    // MARK: - New Tests

    func test_spam_auto_expiration() {
        let reminder = makeReminder(urgency: .high)
        reminder.isSpamming = true
        // Set clock to past the max spam duration
        stubbedDate = reminder.date.addingTimeInterval(NotificationService.maxSpamDuration + 1)
        
        service.rescheduleSpamIfNeeded(for: reminder)
        // Ensure that it dispatches the state change to false on main thread correctly.
        let exp = expectation(description: "waited for async")
        DispatchQueue.main.async {
            XCTAssertFalse(reminder.isSpamming)
            XCTAssertTrue(reminder.hasBeenStopped)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }

    func test_past_due_reminders_dont_schedule_in_past() {
        let reminder = makeReminder(urgency: .meeting, secondsFromNow: -10000)
        let exp = expectation(description: "scheduled")
        service.scheduleNotifications(for: reminder) {
            XCTAssertEqual(self.mock.addedRequests.count, 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }

    func test_auth_denied_path() {
        mock.authorizationGranted = false
        let exp = expectation(description: "auth")
        service.requestAuthorization { granted in
            XCTAssertFalse(granted)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
}
