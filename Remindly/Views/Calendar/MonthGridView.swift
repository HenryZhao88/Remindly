import SwiftUI
import SwiftData

struct MonthGridView: View {
    @Query(sort: \Reminder.date) private var reminders: [Reminder]
    @Binding var selectedDate: Date?
    @State private var displayedMonth: Date = Calendar.current.startOfMonth(for: Date())

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 1), count: 7)
    private let dayHeaders = ["S", "M", "T", "W", "T", "F", "S"]

    private func remindersOnDay(_ date: Date) -> [Reminder] {
        reminders.filter { DateHelpers.isSameDay($0.date, date) }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Month navigation header
            HStack {
                Button { changeMonth(by: -1) } label: {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text(displayedMonth.formatted(.dateTime.month(.wide).year()))
                    .font(.headline)
                Spacer()
                Button { changeMonth(by: 1) } label: {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            // Day-of-week headers
            LazyVGrid(columns: columns, spacing: 1) {
                ForEach(dayHeaders, id: \.self) { h in
                    Text(h)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                }
            }
            .background(Color(.systemGroupedBackground))

            // Day cells
            LazyVGrid(columns: columns, spacing: 1) {
                ForEach(Array(DateHelpers.monthGridDays(for: displayedMonth).enumerated()), id: \.offset) { _, date in
                    DayCellView(
                        date: date,
                        reminders: date.map { remindersOnDay($0) } ?? [],
                        isSelected: date.map { d in selectedDate.map { DateHelpers.isSameDay(d, $0) } ?? false } ?? false
                    )
                    .background(Color(.systemBackground))
                    .onTapGesture {
                        if let date { selectedDate = date }
                    }
                }
            }
            .background(Color(.separator))
        }
    }

    private func changeMonth(by value: Int) {
        guard let newMonth = Calendar.current.date(byAdding: .month, value: value, to: displayedMonth) else { return }
        displayedMonth = newMonth
        selectedDate = nil
    }
}

private extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        self.date(from: self.dateComponents([.year, .month], from: date)) ?? date
    }
}
