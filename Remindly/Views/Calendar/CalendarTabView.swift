import SwiftUI

struct CalendarTabView: View {
    @EnvironmentObject private var settings: AppSettings
    @State private var selectedDate: Date? = nil
    @State private var showingDayPopup = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    if settings.calendarViewMode == .month {
                        MonthGridView(selectedDate: $selectedDate)
                    } else {
                        WeekGridView(selectedDate: $selectedDate)
                    }
                }
            }
            .navigationTitle("Calendar")
            .onChange(of: selectedDate) { _, newDate in
                showingDayPopup = newDate != nil
            }
            .sheet(isPresented: $showingDayPopup, onDismiss: { selectedDate = nil }) {
                if let date = selectedDate {
                    DayPopupView(date: date)
                }
            }
        }
    }
}
