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

    override func setUp() {
        super.setUp()
        mock = MockNotificationCenter()
        service = NotificationService(center: mock)
        // Disable BGTaskScheduler in tests to avoid unregistered-identifier assertion.
        service.backgroundRefreshScheduler = {}
    }

    func makeReminder(urgency: UrgencyLevel, secondsFromNow: TimeInterval = 7200) -> Reminder {
        Reminder(title: "Test", date: Date().addingTimeInterval(secondsFromNow), urgency: urgency)
    }

    func test_none_schedules_one_notification() {
        let reminder = makeReminder(urgency: .none)
        service.scheduleNotifications(for: reminder)
        let exp = expectation(description: "scheduled")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.mock.addedRequests.count, 1)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }

    func test_low_schedules_two_notifications() {
        let reminder = makeReminder(urgency: .low)
        service.scheduleNotifications(for: reminder)
        let exp = expectation(description: "scheduled")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.mock.addedRequests.count, 2)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }

    func test_meeting_schedules_three_notifications() {
        let reminder = makeReminder(urgency: .meeting)
        service.scheduleNotifications(for: reminder)
        let exp = expectation(description: "scheduled")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.mock.addedRequests.count, 3)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }

    func test_high_schedules_spam_burst() {
        let reminder = makeReminder(urgency: .high)
        service.scheduleNotifications(for: reminder)
        let exp = expectation(description: "scheduled")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.mock.addedRequests.count, NotificationService.spamBurstCount)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }

    func test_notification_identifiers_use_reminder_id_as_prefix() {
        let reminder = makeReminder(urgency: .none)
        service.scheduleNotifications(for: reminder)
        let exp = expectation(description: "scheduled")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.mock.addedRequests.allSatisfy {
                $0.identifier.hasPrefix(reminder.id.uuidString)
            })
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }

    func test_cancel_removes_pending_by_prefix() {
        let reminder = makeReminder(urgency: .none)
        service.scheduleNotifications(for: reminder)
        let exp = expectation(description: "cancelled")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.service.cancelNotifications(for: reminder)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let removed = self.mock.removedPrefixes
                XCTAssertTrue(removed.contains(where: { $0.hasPrefix(reminder.id.uuidString) }))
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 2)
    }

    func test_custom_with_15min_schedules_two_notifications() {
        let reminder = makeReminder(urgency: .custom)
        var config = CustomUrgencyConfig()
        config.notify15min = true
        reminder.customConfig = config
        service.scheduleNotifications(for: reminder)
        let exp = expectation(description: "scheduled")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // 15 min before + at event time = 2
            XCTAssertEqual(self.mock.addedRequests.count, 2)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
}
