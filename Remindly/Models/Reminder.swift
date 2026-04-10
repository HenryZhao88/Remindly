import Foundation
import SwiftData

@Model
final class Reminder {
    var id: UUID
    var title: String
    var date: Date
    /// Raw storage for UrgencyLevel enum (SwiftData stores as String).
    var urgencyRaw: String
    /// JSON-encoded CustomUrgencyConfig; non-nil only when urgencyRaw == "Custom".
    var customConfigData: Data?
    var notes: String?
    /// True while high-urgency spam notifications are actively firing.
    var isSpamming: Bool
    /// True if the user has explicitly stopped the high urgency spam for this event.
    var hasBeenStopped: Bool

    var urgency: UrgencyLevel {
        get { UrgencyLevel(rawValue: urgencyRaw) ?? .none }
        set { urgencyRaw = newValue.rawValue }
    }

    var customConfig: CustomUrgencyConfig {
        get {
            guard let data = customConfigData,
                  let config = try? JSONDecoder().decode(CustomUrgencyConfig.self, from: data)
            else { return CustomUrgencyConfig() }
            return config
        }
        set {
            // CustomUrgencyConfig only contains Bool fields so encoding cannot fail.
            customConfigData = try? JSONEncoder().encode(newValue)
        }
    }

    init(title: String, date: Date, urgency: UrgencyLevel = .none, notes: String? = nil) {
        self.id = UUID()
        self.title = title
        self.date = date
        self.urgencyRaw = urgency.rawValue
        self.isSpamming = false
        self.hasBeenStopped = false
        self.notes = notes
    }
}
