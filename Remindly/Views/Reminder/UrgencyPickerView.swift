import SwiftUI

private extension UrgencyLevel {
    var description: String {
        switch self {
        case .none:    return "Notifies once at event time."
        case .low:     return "Notifies 1 hour before and again at event time."
        case .meeting: return "Notifies 30 min before, 10 min before, and at event time."
        case .high:    return "Sends nonstop notifications at event time until you tap Stop."
        case .custom:  return "You choose when to be reminded. Optionally enable nonstop spam at event time."
        }
    }
}

struct UrgencyPickerView: View {
    @EnvironmentObject private var settings: AppSettings
    @Binding var selected: UrgencyLevel
    @Binding var customConfig: CustomUrgencyConfig

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(UrgencyLevel.allCases) { level in
                        Button {
                            selected = level
                        } label: {
                            Text(level.rawValue)
                                .font(.subheadline.weight(.semibold))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(settings.color(for: level))
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white, lineWidth: selected == level ? 2 : 0)
                                )
                        }
                    }
                }
                .padding(.horizontal, 1)
            }

            HStack(spacing: 6) {
                Image(systemName: "info.circle")
                    .font(.caption)
                    .foregroundStyle(settings.color(for: selected))
                Text(selected.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(settings.color(for: selected).opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .animation(.easeInOut(duration: 0.15), value: selected)

            if selected == .custom {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Remind me before:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Toggle("15 minutes before", isOn: $customConfig.notify15min)
                    Toggle("30 minutes before", isOn: $customConfig.notify30min)
                    Toggle("45 minutes before", isOn: $customConfig.notify45min)
                    Divider()
                    Toggle("Spam at event time (like High)", isOn: $customConfig.spamAtEventTime)
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}
