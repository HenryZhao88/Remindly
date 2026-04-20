import SwiftUI

final class AppSettings: ObservableObject {
    @AppStorage("calendarViewMode") private var calendarViewModeRaw: String = CalendarViewMode.month.rawValue
    @AppStorage("color_None")    var colorNone:    String = UrgencyLevel.none.defaultHex
    @AppStorage("color_Low")     var colorLow:     String = UrgencyLevel.low.defaultHex
    @AppStorage("color_Meeting") var colorMeeting: String = UrgencyLevel.meeting.defaultHex
    @AppStorage("color_High")    var colorHigh:    String = UrgencyLevel.high.defaultHex
    @AppStorage("color_Custom")  var colorCustom:  String = UrgencyLevel.custom.defaultHex

    var calendarViewMode: CalendarViewMode {
        get { CalendarViewMode(rawValue: calendarViewModeRaw) ?? .month }
        set { calendarViewModeRaw = newValue.rawValue }
    }

    func color(for urgency: UrgencyLevel) -> Color {
        switch urgency {
        case .none:    return Color(hex: colorNone)
        case .low:     return Color(hex: colorLow)
        case .meeting: return Color(hex: colorMeeting)
        case .high:    return Color(hex: colorHigh)
        case .custom:  return Color(hex: colorCustom)
        }
    }

    func setColor(_ color: Color, for urgency: UrgencyLevel) {
        objectWillChange.send()
        let hex = color.toHex()
        switch urgency {
        case .none:    colorNone    = hex
        case .low:     colorLow     = hex
        case .meeting: colorMeeting = hex
        case .high:    colorHigh    = hex
        case .custom:  colorCustom  = hex
        }
    }
}
