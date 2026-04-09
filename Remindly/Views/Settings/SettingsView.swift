import SwiftUI
import UserNotifications

struct SettingsView: View {
    @EnvironmentObject private var settings: AppSettings
    @State private var notificationStatus: String = "Checking..."

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
                        Text(notificationStatus)
                            .foregroundStyle(notificationStatus == "Granted" ? .green : .red)
                    }
                    if notificationStatus != "Granted" {
                        Button("Open Settings") {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
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
                notificationStatus = s.authorizationStatus == .authorized ? "Granted" : "Denied"
            }
        }
    }
}
