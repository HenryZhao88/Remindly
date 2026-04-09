import Foundation

enum UrgencyLevel: String, Codable, CaseIterable, Identifiable {
    case none = "None"
    case low = "Low"
    case meeting = "Meeting"
    case high = "High"
    case custom = "Custom"

    var id: String { rawValue }

    /// Time offsets in seconds relative to event time. Negative = before event.
    var leadOffsets: [TimeInterval] {
        switch self {
        case .none:    return [0]
        case .low:     return [-3600, 0]
        case .meeting: return [-1800, -600, 0]
        case .high:    return []   // spam handled separately
        case .custom:  return []   // handled by CustomUrgencyConfig
        }
    }

    var isSpam: Bool { self == .high }

    var defaultHex: String {
        switch self {
        case .none:    return "#34C759"
        case .low:     return "#FF9500"
        case .meeting: return "#FF6B00"
        case .high:    return "#FF3B30"
        case .custom:  return "#5E5CE6"
        }
    }
}
