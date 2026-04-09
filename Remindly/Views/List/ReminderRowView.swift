import SwiftUI

struct ReminderRowView: View {
    @EnvironmentObject private var settings: AppSettings
    let reminder: Reminder

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(settings.color(for: reminder.urgency))
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 2) {
                Text(reminder.title)
                    .font(.body)
                Text(reminder.date.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(reminder.urgency.rawValue)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(settings.color(for: reminder.urgency))
        }
        .padding(.vertical, 4)
    }
}
