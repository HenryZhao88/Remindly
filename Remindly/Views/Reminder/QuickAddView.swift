import SwiftUI
import SwiftData

/// Compact bottom sheet for quickly adding a reminder from a tapped calendar date.
struct QuickAddView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let prefilledDate: Date

    @State private var title: String = ""
    @State private var selectedTime: Date = Date()
    @State private var urgency: UrgencyLevel = .none
    @State private var customConfig: CustomUrgencyConfig = CustomUrgencyConfig()

    private var canSave: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty }

    private var combinedDate: Date {
        let cal = Calendar.current
        var dc = cal.dateComponents([.year, .month, .day], from: prefilledDate)
        let tc = cal.dateComponents([.hour, .minute], from: selectedTime)
        dc.hour = tc.hour
        dc.minute = tc.minute
        return cal.date(from: dc) ?? prefilledDate
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                TextField("Title", text: $title)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                HStack {
                    DatePicker("Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                }
                .padding(.horizontal)

                UrgencyPickerView(selected: $urgency, customConfig: $customConfig)
                    .padding(.horizontal)

                Button("Add Reminder") {
                    let reminder = Reminder(title: title, date: combinedDate, urgency: urgency)
                    reminder.customConfig = customConfig
                    modelContext.insert(reminder)
                    NotificationService.shared.scheduleNotifications(for: reminder)

                    // Bug 4 fix: set isSpamming if spam should already be active
                    if reminder.shouldStartSpammingNow() {
                        reminder.isSpamming = true
                    }
                    try? modelContext.save()

                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canSave)

                Spacer()
            }
            .padding(.top)
            .navigationTitle(prefilledDate.formatted(date: .abbreviated, time: .omitted))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}
