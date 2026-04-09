import UserNotifications

protocol NotificationScheduling {
    func add(_ request: UNNotificationRequest, withCompletionHandler: ((Error?) -> Void)?)
    func removePendingNotificationRequests(withIdentifiers identifiers: [String])
    func removeDeliveredNotifications(withIdentifiers identifiers: [String])
    func getPendingNotificationRequests(completionHandler: @escaping ([UNNotificationRequest]) -> Void)
    func requestAuthorization(options: UNAuthorizationOptions, completionHandler: @escaping (Bool, Error?) -> Void)
}

extension UNUserNotificationCenter: NotificationScheduling {}
