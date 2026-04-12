import SwiftUI
import SwiftData

struct ReminderListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Reminder.date, order: .forward) private var reminders: [Reminder]
    @State private var editingReminder: Reminder? = nil
    @State private var selectedTab = 0

    private var activeReminders: [Reminder] {
        let now = Date()
        return reminders.filter { $0.date >= now || $0.isSpamming }
    }

    private var pastReminders: [Reminder] {
        let now = Date()
        return Array(reminders.filter { $0.date < now && !$0.isSpamming }.reversed())
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("", selection: $selectedTab) {
                    Text("Active").tag(0)
                    Text("Past").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)

                if selectedTab == 0 {
                    activeTabContent
                } else {
                    pastTabContent
                }
            }
            .navigationTitle("Reminders")
            .sheet(item: $editingReminder) { reminder in
                ReminderFormView(editingReminder: reminder, onSave: { editingReminder = nil })
            }
        }
    }

    @ViewBuilder
    private var activeTabContent: some View {
        if activeReminders.isEmpty {
            ContentUnavailableView(
                "No Upcoming Reminders",
                systemImage: "bell.slash",
                description: Text("Add a reminder from the + tab.")
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List {
                ForEach(activeReminders) { reminder in
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
            .listStyle(.plain)
        }
    }

    @ViewBuilder
    private var pastTabContent: some View {
        if pastReminders.isEmpty {
            ContentUnavailableView(
                "No Past Reminders",
                systemImage: "clock",
                description: Text("Past reminders will appear here.")
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List {
                ForEach(pastReminders) { reminder in
                    ReminderRowView(reminder: reminder)
                        .opacity(0.55)
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
            .listStyle(.plain)
        }
    }

    private func delete(_ reminder: Reminder) {
        NotificationService.shared.cancelNotifications(for: reminder)
        modelContext.delete(reminder)
    }
}
