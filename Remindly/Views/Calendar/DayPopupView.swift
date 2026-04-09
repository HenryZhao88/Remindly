import SwiftUI
import SwiftData

struct DayPopupView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var settings: AppSettings
    @Query(sort: \Reminder.date) private var allReminders: [Reminder]

    let date: Date
    @State private var showingQuickAdd = false

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
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
