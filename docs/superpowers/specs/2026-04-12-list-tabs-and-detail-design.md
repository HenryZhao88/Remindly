# List Tabs, Detail View & Delete — Design Spec
**Date:** 2026-04-12
**Platform:** iOS 17+, SwiftUI
**Scope:** ReminderListView, DayPopupView, ReminderFormView

---

## Overview

Three improvements to how reminders are browsed and managed:

1. The List tab gains an **Active / Past segmented control** so users can see both upcoming and historical reminders.
2. **Tapping any reminder** (from the list or the calendar day popup) opens the existing edit form.
3. **Delete** is available everywhere: swipe-to-delete in both list tabs and in the calendar day popup, plus a dedicated Delete button inside the edit form.

---

## 1. List Tab — Active / Past Tabs

### Segmented Control
A `Picker` with `.segmented` style sits directly below the navigation title. Two segments: **Active** and **Past**.

### Active tab
- **Content:** reminders where `date >= Date() || isSpamming`
- **Sort:** chronological, soonest first (ascending `date`)
- **Empty state:** "No upcoming reminders" with `bell.slash` system image
- **Row interaction:** tap → open edit form; swipe left → Delete action (destructive, red)

### Past tab
- **Content:** reminders where `date < Date() && !isSpamming`
- **Sort:** reverse chronological, most recent first (descending `date`)
- **Visual treatment:** past rows rendered at reduced opacity (0.55) to signal they are historical
- **Empty state:** "No past reminders" with `clock` system image
- **Row interaction:** tap → open edit form; swipe left → Delete action (destructive, red)

### Data sourcing
A single `@Query(sort: \Reminder.date, order: .forward)` fetches all reminders. Two computed properties — `activeReminders` and `pastReminders` — filter and (for past) reverse the result. No second query needed.

### Edit sheet
Both tabs use the same `@State private var editingReminder: Reminder?`. Tapping a row sets it; the `.sheet(item:)` presents `ReminderFormView(editingReminder:onSave:)` as before.

---

## 2. Calendar Day Popup — Tap & Delete

### Tap to edit
Each row in `DayPopupView` gains an `onTapGesture` that sets a new `@State private var editingReminder: Reminder?`. A `.sheet(item: $editingReminder)` presents `ReminderFormView`. Works for both future and past dates.

### Swipe to delete
Each row gains a `.swipeActions(edge: .trailing)` with a destructive **Delete** button. Calls `NotificationService.shared.cancelNotifications(for:)` then `modelContext.delete(reminder)`. Works for both future and past reminders.

### Chevron indicator
A `›` chevron is added to the trailing side of each row (before the time label) to communicate tappability.

---

## 3. Edit Form — Delete Button

A **"Delete Reminder"** button is added as its own `Section` at the bottom of `ReminderFormView`, below the Save button section. It is shown only when `editingReminder != nil` (i.e., not shown when creating a new reminder).

Pressing it:
1. Cancels all scheduled notifications for the reminder
2. Deletes the reminder from the model context
3. Calls `onSave?()` to dismiss the sheet (reusing the existing dismiss hook)

This gives users a quick in-form delete path without having to dismiss and swipe.

---

## Affected Files

| File | Change |
|------|--------|
| `Views/List/ReminderListView.swift` | Add segmented picker, active/past computed properties, past tab list with reversed sort and reduced opacity |
| `Views/Calendar/DayPopupView.swift` | Add `editingReminder` state, tap-to-edit sheet, swipe-to-delete, chevron on rows |
| `Views/Reminder/ReminderFormView.swift` | Add delete button section (visible only in edit mode) |

No new files. No model changes. No new services.

---

## Out of Scope
- Marking reminders as "complete" (separate concept from delete)
- Editing from the calendar month/week grid directly (only from day popup)
- Batch delete
