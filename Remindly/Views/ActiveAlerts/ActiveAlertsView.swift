import SwiftUI
import SwiftData

struct ActiveAlertsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(filter: #Predicate<Reminder> { $0.isSpamming }) private var spammingReminders: [Reminder]

    var body: some View {
        NavigationStack {
            Group {
                if spammingReminders.isEmpty {
                    ContentUnavailableView("All Clear", systemImage: "bell.slash")
                } else {
                    List(spammingReminders) { reminder in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(reminder.title).font(.headline)
                                Text(reminder.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button("STOP") {
                                stop(reminder)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.red)
                            .accessibilityLabel("Stop active alert for \(reminder.title)")
                        }
                    }
                }
            }
            .navigationTitle("Active Alerts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .onChange(of: spammingReminders.count) { _, count in
                if count == 0 { dismiss() }
            }
        }
    }

    private func stop(_ reminder: Reminder) {
        reminder.isSpamming = false
        reminder.hasBeenStopped = true
        NotificationService.shared.cancelNotifications(for: reminder)
    }
}
