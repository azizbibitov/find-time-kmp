import SwiftUI
import SharedLogic

struct FindMeeting: View {
    @EnvironmentObject private var timezoneItems: TimezoneItems
    private var timezoneHelper = TimeZoneHelperImpl()
    @State private var meetingHours: [Int] = []
    @State private var showHoursDialog = false
    @State private var startDate = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!
    @State private var endDate = Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: Date())!

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Time Range")) {
                    DatePicker("Start Time", selection: $startDate, displayedComponents: .hourAndMinute)
                    DatePicker("End Time", selection: $endDate, displayedComponents: .hourAndMinute)
                }
                Section(header: Text("Time Zones")) {
                    ForEach(Array(timezoneItems.selectedTimezones), id: \.self) { timezone in
                        Text(timezone)
                    }
                }
                Section {
                    Button(action: search) {
                        HStack {
                            Spacer()
                            Text("Search").bold()
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Find Meeting Time")
        }
        .sheet(isPresented: $showHoursDialog) {
            HourSheet(hours: $meetingHours)
        }
    }

    func search() {
        meetingHours.removeAll()
        let startHour = Calendar.current.component(.hour, from: startDate)
        let endHour = Calendar.current.component(.hour, from: endDate)
        let hours = timezoneHelper.search(
            startHour: Int32(startHour),
            endHour: Int32(endHour),
            timezoneStrings: Array(timezoneItems.selectedTimezones)
        )
        meetingHours += hours.map { Int(truncating: $0) }
        showHoursDialog = true
    }
}

#Preview {
    FindMeeting().environmentObject(TimezoneItems())
}
