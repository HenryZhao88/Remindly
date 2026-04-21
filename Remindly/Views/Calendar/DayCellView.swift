import SwiftUI

struct DayCellView: View {
    @EnvironmentObject private var settings: AppSettings
    let date: Date?
    let reminders: [Reminder]
    let isSelected: Bool

    private var isToday: Bool {
        guard let date else { return false }
        return Calendar.current.isDateInToday(date)
    }

    private var dayNumber: String {
        guard let date else { return "" }
        return Calendar.current.component(.day, from: date).description
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            // Day number
            ZStack {
                if isToday {
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 20, height: 20)
                }
                Text(dayNumber)
                    .font(.caption2.weight(isToday ? .bold : .regular))
                    .foregroundStyle(isToday ? .white : (date == nil ? .clear : .primary))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Event pills — show up to 2, then overflow count
            let visible = Array(reminders.prefix(2))
            let overflow = reminders.count - visible.count
            ForEach(visible) { reminder in
                Text(reminder.title)
                    .font(.caption2.weight(.medium))
                    .lineLimit(1)
                    .padding(.horizontal, 3)
                    .padding(.vertical, 1)
                    .background(settings.color(for: reminder.urgency).opacity(0.2))
                    .foregroundStyle(settings.color(for: reminder.urgency))
                    .clipShape(RoundedRectangle(cornerRadius: 3))
            }
            if overflow > 0 {
                Text("+\(overflow) more")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(3)
        .frame(minHeight: 56)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .stroke(isSelected ? Color.accentColor : .clear, lineWidth: 1.5)
        )
    }
}
