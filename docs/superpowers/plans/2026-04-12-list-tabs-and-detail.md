# List Tabs, Detail View & Delete Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Active/Past segmented tabs to the List view, tap-to-edit on all reminder rows, and delete actions everywhere reminders appear.

**Architecture:** Three surgical edits to existing view files — no new files, no model changes. Each task is independently committable. Since these are pure SwiftUI view changes, verification is build-time (no compiler errors) plus manual smoke test in the simulator.

**Tech Stack:** SwiftUI, SwiftData, existing `ReminderFormView` / `NotificationService` / `ReminderRowView`

---

## File Map

| File | Change |
|------|--------|
| `Remindly/Views/List/ReminderListView.swift` | Full rewrite: add `selectedTab` state, `activeReminders`/`pastReminders` computed props, segmented `Picker`, two tab bodies |
| `Remindly/Views/Calendar/DayPopupView.swift` | Add `modelContext`, `editingReminder` state, chevron on rows, `.onTapGesture`, `.swipeActions`, edit sheet |
| `Remindly/Views/Reminder/ReminderFormView.swift` | Add `@Environment(\.dismiss)`, "Delete Reminder" section at bottom (edit mode only), `deleteReminder()` helper |

---

## Task 1: ReminderListView — Active / Past Segmented Tabs

**Files:**
- Modify: `Remindly/Views/List/ReminderListView.swift`

- [ ] **Step 1: Replace the entire file with the new implementation**

```swift
import SwiftUI
import SwiftData

struct ReminderListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Reminder.date, order: .forward) private var reminders: [Reminder]
    @State private var editingReminder: Reminder? = nil
    @State private var selectedTab = 0

    private var activeReminders: [Reminder] {
        reminders.filter { $0.date >= Date() || $0.isSpamming }
    }

    private var pastReminders: [Reminder] {
        Array(reminders.filter { $0.date < Date() && !$0.isSpamming }.reversed())
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
```

- [ ] **Step 2: Build and verify no compile errors**

Open the project in Xcode and build for any simulator (`Cmd+B`). Expected: build succeeds with no errors.

- [ ] **Step 3: Smoke test in simulator**

- Active tab shows future reminders sorted soonest-first
- Past tab shows past reminders sorted most-recent-first at 55% opacity
- Tapping any row opens the edit sheet
- Swipe left on any row reveals a red Delete button; tapping it removes the reminder and cancels its notifications
- Switching between tabs is instant with no layout jump

- [ ] **Step 4: Commit**

```bash
git add Remindly/Views/List/ReminderListView.swift
git commit -m "feat: add Active/Past segmented tabs to ReminderListView"
```

---

## Task 2: DayPopupView — Tap to Edit + Swipe to Delete

**Files:**
- Modify: `Remindly/Views/Calendar/DayPopupView.swift`

- [ ] **Step 1: Replace the entire file with the new implementation**

```swift
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
```

- [ ] **Step 2: Build and verify no compile errors**

`Cmd+B` in Xcode. Expected: build succeeds with no errors.

- [ ] **Step 3: Smoke test in simulator**

- Tap any date on the calendar → day popup opens
- Each reminder row shows a `›` chevron on the right
- Tapping a row opens the edit sheet; saving updates the reminder in-place
- Swipe left on a row → red Delete button; tapping removes the reminder from the list and the calendar cell immediately
- Works on past dates as well (tap a past date, verify rows still appear with delete + tap-to-edit)

- [ ] **Step 4: Commit**

```bash
git add Remindly/Views/Calendar/DayPopupView.swift
git commit -m "feat: add tap-to-edit and swipe-to-delete in DayPopupView"
```

---

## Task 3: ReminderFormView — Delete Button in Edit Mode

**Files:**
- Modify: `Remindly/Views/Reminder/ReminderFormView.swift`

- [ ] **Step 1: Add `@Environment(\.dismiss)` and a delete section**

The three changes are:
1. Add `@Environment(\.dismiss) private var dismiss` after the existing `@EnvironmentObject` line
2. Add a new `Section` for the delete button after the Save section (inside the `Form`)
3. Add a `deleteReminder()` private method

Replace the full file content:

```swift
import SwiftUI
import SwiftData

struct ReminderFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var settings: AppSettings

    /// Non-nil when editing an existing reminder.
    var editingReminder: Reminder?
    /// Called after a successful save or delete. Used when embedded in a sheet.
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

                if editingReminder != nil {
                    Section {
                        Button("Delete Reminder", role: .destructive) {
                            deleteReminder()
                        }
                        .frame(maxWidth: .infinity)
                    }
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
                if self.onSave == nil {
                    self.resetForm()
                } else {
                    self.onSave?()
                }
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

            if onSave == nil {
                resetForm()
            } else {
                onSave?()
            }
        }
    }

    private func deleteReminder() {
        guard let r = editingReminder else { return }
        NotificationService.shared.cancelNotifications(for: r)
        modelContext.delete(r)
        onSave?()
        dismiss()
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
```

- [ ] **Step 2: Build and verify no compile errors**

`Cmd+B` in Xcode. Expected: build succeeds with no errors.

- [ ] **Step 3: Smoke test in simulator**

- Open the Add tab → confirm "Delete Reminder" button is **not** present (new reminder mode)
- Tap an existing reminder in the List or Calendar to open the edit form → confirm red "Delete Reminder" button appears at the bottom
- Tap "Delete Reminder" → confirm the sheet dismisses and the reminder is gone from the list and calendar
- Confirm the deleted reminder's notifications are cancelled (no spurious notification fires)

- [ ] **Step 4: Commit**

```bash
git add Remindly/Views/Reminder/ReminderFormView.swift
git commit -m "feat: add Delete Reminder button to edit form"
```
