import Foundation

enum DateHelpers {
    /// Returns 42 optional Dates (6 rows × 7 columns) for a month grid.
    /// Nil entries represent padding days from adjacent months.
    static func monthGridDays(for month: Date) -> [Date?] {
        let cal = Calendar.current
        guard let firstDay = cal.date(from: cal.dateComponents([.year, .month], from: month)),
              let range = cal.range(of: .day, in: .month, for: month) else { return [] }

        let weekdayOfFirst = cal.component(.weekday, from: firstDay) - 1 // 0 = Sunday
        var days: [Date?] = Array(repeating: nil, count: weekdayOfFirst)
        for offset in 0..<range.count {
            days.append(cal.date(byAdding: .day, value: offset, to: firstDay))
        }
        while days.count < 42 { days.append(nil) }
        return days
    }

    /// Returns 7 Dates for the week containing `date`, starting Sunday.
    static func weekDays(for date: Date) -> [Date] {
        let cal = Calendar.current
        let weekday = cal.component(.weekday, from: date) - 1
        guard let sunday = cal.date(byAdding: .day, value: -weekday, to: date) else { return [] }
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: sunday) }
    }

    static func isSameDay(_ a: Date, _ b: Date) -> Bool {
        Calendar.current.isDate(a, inSameDayAs: b)
    }
}
