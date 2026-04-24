import SwiftUI

enum AppearanceMode: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

final class AppSettings: ObservableObject {
    @AppStorage("calendarViewMode") private var calendarViewModeRaw: String = CalendarViewMode.month.rawValue
    @AppStorage("appearanceMode") private var appearanceModeRaw: String = AppearanceMode.system.rawValue
    @AppStorage("color_None")    var colorNone:    String = UrgencyLevel.none.defaultHex
    @AppStorage("color_Low")     var colorLow:     String = UrgencyLevel.low.defaultHex
    @AppStorage("color_Meeting") var colorMeeting: String = UrgencyLevel.meeting.defaultHex
    @AppStorage("color_High")    var colorHigh:    String = UrgencyLevel.high.defaultHex
    @AppStorage("color_Custom")  var colorCustom:  String = UrgencyLevel.custom.defaultHex

    var calendarViewMode: CalendarViewMode {
        get { CalendarViewMode(rawValue: calendarViewModeRaw) ?? .month }
        set {
            objectWillChange.send()
            calendarViewModeRaw = newValue.rawValue
        }
    }

    var appearanceMode: AppearanceMode {
        get { AppearanceMode(rawValue: appearanceModeRaw) ?? .system }
        set {
            objectWillChange.send()
            appearanceModeRaw = newValue.rawValue
        }
    }

    func color(for urgency: UrgencyLevel) -> Color {
        switch urgency {
        case .none:    return Color(hex: colorNone) ?? Color(hex: UrgencyLevel.none.defaultHex)!
        case .low:     return Color(hex: colorLow) ?? Color(hex: UrgencyLevel.low.defaultHex)!
        case .meeting: return Color(hex: colorMeeting) ?? Color(hex: UrgencyLevel.meeting.defaultHex)!
        case .high:    return Color(hex: colorHigh) ?? Color(hex: UrgencyLevel.high.defaultHex)!
        case .custom:  return Color(hex: colorCustom) ?? Color(hex: UrgencyLevel.custom.defaultHex)!
        }
    }

    func setColor(_ color: Color, for urgency: UrgencyLevel) {
        let hex = color.toHex()
        objectWillChange.send()
        switch urgency {
        case .none:    colorNone    = hex
        case .low:     colorLow     = hex
        case .meeting: colorMeeting = hex
        case .high:    colorHigh    = hex
        case .custom:  colorCustom  = hex
        }
    }
}
