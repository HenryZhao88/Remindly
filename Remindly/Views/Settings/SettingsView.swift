import SwiftUI
import UserNotifications

struct SettingsView: View {
    @EnvironmentObject private var settings: AppSettings
    @State private var notificationStatus: UNAuthorizationStatus?

    var body: some View {
        NavigationStack {
            Form {
                Section("Calendar") {
                    Picker("Default View", selection: Binding(
                        get: { settings.calendarViewMode },
                        set: { settings.calendarViewMode = $0 }
                    )) {
                        Text("Month").tag(CalendarViewMode.month)
                        Text("Week").tag(CalendarViewMode.week)
                    }
                }

                Section("Appearance") {
                    Picker("Theme", selection: Binding(
                        get: { settings.appearanceMode },
                        set: { settings.appearanceMode = $0 }
                    )) {
                        ForEach(AppearanceMode.allCases) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Urgency Colors") {
                    ForEach(UrgencyLevel.allCases) { level in
                        ColorPicker(level.rawValue, selection: Binding(
                            get: { settings.color(for: level) },
                            set: { settings.setColor($0, for: level) }
                        ))
                    }
                }

                Section("Notifications") {
                    HStack {
                        Text("Permission")
                        Spacer()
                        Text(notificationStatusLabel)
                            .foregroundStyle(notificationStatusColor)
                    }
                    if notificationStatus == .notDetermined {
                        Button("Request Permission") {
                            NotificationService.shared.requestAuthorization { _ in
                                checkNotificationStatus()
                            }
                        }
                    } else if let notificationStatus, notificationStatus != .authorized {
                        Button("Open Settings") {
                            openAppSettings()
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear { checkNotificationStatus() }
        }
    }

    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { s in
            DispatchQueue.main.async {
                notificationStatus = s.authorizationStatus
            }
        }
    }

    private var notificationStatusLabel: String {
        switch notificationStatus {
        case .authorized:
            return "Granted"
        case .denied:
            return "Denied"
        case .notDetermined:
            return "Not Asked"
        case .provisional:
            return "Provisional"
        case .ephemeral:
            return "Ephemeral"
        case nil:
            return "Checking..."
        @unknown default:
            return "Unknown"
        }
    }

    private var notificationStatusColor: Color {
        switch notificationStatus {
        case .authorized, .provisional, .ephemeral:
            return .green
        case .denied:
            return .red
        case .notDetermined, nil:
            return .secondary
        @unknown default:
            return .orange
        }
    }

    private func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
