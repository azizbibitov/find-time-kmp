import SwiftUI
import SharedLogic

struct TimezoneView: View {
    @EnvironmentObject private var timezoneItems: TimezoneItems
    private var timezoneHelper = TimeZoneHelperImpl()
    @State private var currentDate = Date()
    @State private var showTimezoneDialog = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            List {
                Section {
                    TimeCard(
                        timezone: timezoneHelper.currentTimeZone(),
                        time: DateFormatter.short.string(from: currentDate),
                        date: DateFormatter.long.string(from: currentDate)
                    )
                    .listRowInsets(.init())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                Section {
                    ForEach(Array(timezoneItems.selectedTimezones), id: \.self) { timezone in
                        NumberTimeCard(
                            timezone: timezone,
                            time: timezoneHelper.getTime(timezoneId: timezone),
                            hours: "\(timezoneHelper.hoursFromTimeZone(otherTimeZoneId: timezone)) hours from local",
                            date: timezoneHelper.getDate(timezoneId: timezone)
                        )
                        .withListModifier()
                        .listRowBackground(Color.clear)
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .listStyle(.plain)
            .onReceive(timer) { input in currentDate = input }
            .navigationTitle("World Clocks")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showTimezoneDialog = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showTimezoneDialog) {
            TimezoneDialog().environmentObject(timezoneItems)
        }
    }

    func deleteItems(at offsets: IndexSet) {
        let timezoneArray = Array(timezoneItems.selectedTimezones)
        for index in offsets {
            timezoneItems.selectedTimezones.remove(timezoneArray[index])
        }
    }
}

#Preview {
    TimezoneView().environmentObject(TimezoneItems())
}
