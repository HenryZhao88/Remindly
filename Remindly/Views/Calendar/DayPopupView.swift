import SwiftUI
import SwiftData

struct DayPopupView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var reminders: [Reminder]
    let date: Date
    @State private var showingQuickAdd = false
    @State private var editingReminder: Reminder? = nil

    init(date: Date) {
        self.date = date
        let cal = Calendar.current
        let start = cal.startOfDay(for: date)
        let end = cal.date(byAdding: .day, value: 1, to: start)!
        _reminders = Query(filter: #Predicate<Reminder> { $0.date >= start && $0.date < end }, sort: \.date)
    }

    var body: some View {
        NavigationStack {
            List {
                if reminders.isEmpty {
                    Text("No reminders")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(reminders) { reminder in
                        ReminderRowView(reminder: reminder)
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
        try? modelContext.save()
    }
}
