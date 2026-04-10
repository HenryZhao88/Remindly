import SwiftUI
import SwiftData

struct ReminderFormView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var settings: AppSettings

    /// Non-nil when editing an existing reminder.
    var editingReminder: Reminder?
    /// Called after a successful save. Used when embedded in a sheet.
    var onSave: (() -> Void)? = nil

    // MARK: Form state
    @State private var title: String = ""
    @State private var selectedDate: Date = Date()
    @State private var selectedTime: Date = Date()
    @State private var hasSetTime: Bool = false
    @State private var urgency: UrgencyLevel = .none
    @State private var customConfig: CustomUrgencyConfig = CustomUrgencyConfig()
    @State private var notes: String = ""

    private var canSave: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty && hasSetTime }

    private var combinedDate: Date {
        let cal = Calendar.current
        var dc = cal.dateComponents([.year, .month, .day], from: selectedDate)
        let tc = cal.dateComponents([.hour, .minute], from: selectedTime)
        dc.hour = tc.hour
        dc.minute = tc.minute
        return cal.date(from: dc) ?? selectedDate
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Title", text: $title)
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                    HStack {
                        DatePicker("Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                            .onChange(of: selectedTime) { _, _ in hasSetTime = true }
                        if !hasSetTime {
                            Text("Required")
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                }

                Section("Urgency") {
                    UrgencyPickerView(selected: $urgency, customConfig: $customConfig)
                }

                Section("Notes") {
                    TextField("Optional notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section {
                    Button("Save Reminder") { save() }
                        .frame(maxWidth: .infinity)
                        .disabled(!canSave)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
            }
            .navigationTitle(editingReminder == nil ? "New Reminder" : "Edit Reminder")
            .onAppear { populateIfEditing() }
        }
    }

    // MARK: - Actions

    private func populateIfEditing() {
        guard let r = editingReminder else { return }
        title = r.title
        selectedDate = r.date
        selectedTime = r.date
        hasSetTime = true
        urgency = r.urgency
        customConfig = r.customConfig
        notes = r.notes ?? ""
    }

    private func save() {
        if let r = editingReminder {
            NotificationService.shared.cancelNotifications(for: r) {
                r.title = self.title
                r.date = self.combinedDate
                r.urgency = self.urgency
                r.customConfig = self.customConfig
                r.notes = self.notes.isEmpty ? nil : self.notes
                NotificationService.shared.scheduleNotifications(for: r)
            }
        } else {
            let reminder = Reminder(
                title: title,
                date: combinedDate,
                urgency: urgency,
                notes: notes.isEmpty ? nil : notes)
            reminder.customConfig = customConfig
            modelContext.insert(reminder)
            NotificationService.shared.scheduleNotifications(for: reminder)
        }
        if onSave == nil {
            resetForm()
        } else {
            onSave?()
        }
    }

    private func resetForm() {
        title = ""
        selectedDate = Date()
        selectedTime = Date()
        hasSetTime = false
        urgency = .none
        customConfig = CustomUrgencyConfig()
        notes = ""
    }
}
