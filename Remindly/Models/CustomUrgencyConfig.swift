import Foundation

struct CustomUrgencyConfig: Codable, Equatable {
    var notify15min: Bool = false
    var notify30min: Bool = false
    var notify45min: Bool = false
    /// When true, NotificationService fires spam-burst notifications at event time (like High urgency).
    /// Does NOT affect `leadOffsets` — spam frequency is handled by NotificationService, not lead times.
    var spamAtEventTime: Bool = false

    /// Offsets in seconds, sorted furthest-before-event first, event time (0) always last.
    var leadOffsets: [TimeInterval] {
        var offsets: [TimeInterval] = []
        if notify45min { offsets.append(-2700) }
        if notify30min { offsets.append(-1800) }
        if notify15min { offsets.append(-900) }
        offsets.append(0)
        return offsets
    }
}
