import SwiftUI
import SwiftData

struct DayPopupView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var settings: AppSettings
    @Query(sort: \Reminder.date) private var allReminders: [Reminder]

    let date: Date
    @State private var showingQuickAdd = false
    @State private var editingReminder: Reminder? = nil

    private var reminders: [Reminder] {
        allReminders.filter { DateHelpers.isSameDay($0.date, date) }
    }

    var body: some View {
        NavigationStack {
            List {
                if reminders.isEmpty {
                    Text("No reminders")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(reminders) { reminder in
                        HStack(spacing: 10) {
                            Circle()
                                .fill(settings.color(for: reminder.urgency))
                                .frame(width: 8, height: 8)
                            Text(reminder.title)
                            Spacer()
                            Text(reminder.date.formatted(date: .omitted, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { editingReminder = reminder }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                deleteReminder(reminder)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .navigationTitle(date.formatted(date: .abbreviated, time: .omitted))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button { showingQuickAdd = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingQuickAdd) {
                QuickAddView(prefilledDate: date)
            }
            .sheet(item: $editingReminder) { reminder in
                ReminderFormView(editingReminder: reminder, onSave: { editingReminder = nil })
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func deleteReminder(_ reminder: Reminder) {
        NotificationService.shared.cancelNotifications(for: reminder)
        modelContext.delete(reminder)
    }
}
