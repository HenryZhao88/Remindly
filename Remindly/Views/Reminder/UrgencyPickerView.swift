import SwiftUI

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
