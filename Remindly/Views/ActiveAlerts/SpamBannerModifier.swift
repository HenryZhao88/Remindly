import SwiftUI
import SwiftData

struct SpamBannerModifier: ViewModifier {
    @Query(filter: #Predicate<Reminder> { $0.isSpamming }) private var spammingReminders: [Reminder]
    @State private var showingAlerts = false

    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            if !spammingReminders.isEmpty {
                Button {
                    showingAlerts = true
                } label: {
                    HStack {
                        Image(systemName: "bell.fill")
                        Text("\(spammingReminders.count) active alert\(spammingReminders.count == 1 ? "" : "s") — tap to stop")
                            .font(.caption.weight(.semibold))
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.red)
                    .foregroundStyle(.white)
                }
                .sheet(isPresented: $showingAlerts) {
                    ActiveAlertsView()
                }
                .transition(.move(edge: .top))
                .animation(.easeInOut, value: spammingReminders.isEmpty)
            }
        }
    }
}

extension View {
    func spamBanner() -> some View {
        modifier(SpamBannerModifier())
    }
}
