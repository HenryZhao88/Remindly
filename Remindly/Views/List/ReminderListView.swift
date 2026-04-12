import SwiftUI
import SwiftData

struct ReminderListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Reminder.date, order: .forward) private var reminders: [Reminder]
    @State private var editingReminder: Reminder? = nil

    private var upcomingReminders: [Reminder] {
        reminders.filter { $0.date >= Date() || $0.isSpamming }
    }

    private var grouped: [(String, [Reminder])] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        var dict: [Date: [Reminder]] = [:]
        for r in upcomingReminders {
            let key = cal.startOfDay(for: r.date)
            dict[key, default: []].append(r)
        }
        return dict.keys.sorted().map { key in
            let label: String
            if cal.isDate(key, inSameDayAs: today) {
                label = "Today — " + key.formatted(.dateTime.month(.abbreviated).day())
            } else {
                label = key.formatted(.dateTime.month(.abbreviated).day())
            }
            return (label, dict[key]!)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if upcomingReminders.isEmpty {
                    ContentUnavailableView("No Reminders", systemImage: "bell.slash",
                                          description: Text("Add a reminder from the + tab."))
                } else {
                    List {
                        ForEach(grouped, id: \.0) { header, items in
                            Section(header) {
                                ForEach(items) { reminder in
                                    ReminderRowView(reminder: reminder)
                                        .contentShape(Rectangle())
                                        .onTapGesture { editingReminder = reminder }
                                        .swipeActions(edge: .trailing) {
                                            Button(role: .destructive) {
                                                delete(reminder)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Reminders")
            .sheet(item: $editingReminder) { reminder in
                ReminderFormView(editingReminder: reminder, onSave: { editingReminder = nil })
            }
        }
    }

    private func delete(_ reminder: Reminder) {
        NotificationService.shared.cancelNotifications(for: reminder)
        modelContext.delete(reminder)
    }
}
