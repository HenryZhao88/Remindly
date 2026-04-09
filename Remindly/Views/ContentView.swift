import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var settings: AppSettings
    @Query(filter: #Predicate<Reminder> { $0.isSpamming }) private var spammingReminders: [Reminder]

    var body: some View {
        TabView {
            CalendarTabView()
                .tabItem { Label("Calendar", systemImage: "calendar") }

            ReminderListView()
                .tabItem { Label("List", systemImage: "list.bullet") }

            ReminderFormView(editingReminder: nil)
                .tabItem { Label("Add", systemImage: "plus.circle.fill") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .spamBanner()
        .onAppear {
            NotificationService.shared.requestAuthorization { _ in }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                for reminder in spammingReminders {
                    NotificationService.shared.rescheduleSpamIfNeeded(for: reminder)
                }
            }
        }
    }
}
