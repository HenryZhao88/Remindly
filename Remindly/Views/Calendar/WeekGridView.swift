import SwiftUI
import SwiftData

struct WeekGridView: View {
    @Query(sort: \Reminder.date) private var reminders: [Reminder]
    @EnvironmentObject private var settings: AppSettings
    @Binding var selectedDate: Date?
    @State private var anchorDate: Date = Date()

    private var weekDays: [Date] { DateHelpers.weekDays(for: anchorDate) }

    private func remindersOnDay(_ date: Date) -> [Reminder] {
        reminders.filter { DateHelpers.isSameDay($0.date, date) }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Week navigation
            HStack {
                Button { changeWeek(by: -1) } label: { Image(systemName: "chevron.left") }
                Spacer()
                Text(weekRangeLabel)
                    .font(.headline)
                Spacer()
                Button { changeWeek(by: 1) } label: { Image(systemName: "chevron.right") }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            // 7-column grid
            HStack(spacing: 2) {
                ForEach(weekDays, id: \.self) { date in
                    VStack(spacing: 4) {
                        Text(date.formatted(.dateTime.weekday(.narrow)))
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)

                        ZStack {
                            if Calendar.current.isDateInToday(date) {
                                Circle().fill(Color.accentColor).frame(width: 22, height: 22)
                            }
                            Text(Calendar.current.component(.day, from: date).description)
                                .font(.caption.weight(Calendar.current.isDateInToday(date) ? .bold : .regular))
                                .foregroundStyle(Calendar.current.isDateInToday(date) ? .white : .primary)
                        }

                        ScrollView {
                            VStack(spacing: 2) {
                                ForEach(remindersOnDay(date)) { reminder in
                                    Text(reminder.title)
                                        .font(.system(size: 8, weight: .medium))
                                        .lineLimit(2)
                                        .padding(3)
                                        .frame(maxWidth: .infinity)
                                        .background(settings.color(for: reminder.urgency))
                                        .foregroundStyle(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 4))
                                }
                            }
                        }
                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(selectedDate.map { DateHelpers.isSameDay($0, date) } ?? false
                                    ? Color.accentColor : .clear, lineWidth: 1.5)
                    )
                    .contentShape(Rectangle())
                    .onTapGesture { selectedDate = date }
                }
            }
            .padding(.horizontal, 4)
            .frame(minHeight: 160)
        }
    }

    private var weekRangeLabel: String {
        guard let first = weekDays.first, let last = weekDays.last else { return "" }
        return "\(first.formatted(.dateTime.month(.abbreviated).day())) – \(last.formatted(.dateTime.month(.abbreviated).day()))"
    }

    private func changeWeek(by value: Int) {
        guard let newAnchor = Calendar.current.date(byAdding: .weekOfYear, value: value, to: anchorDate) else { return }
        anchorDate = newAnchor
        selectedDate = nil
    }
}
