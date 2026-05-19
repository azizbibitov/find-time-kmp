import SwiftUI
import SharedLogic

extension String: @retroactive Identifiable {
    public var id: String { return self }
}

struct TimezoneDialog: View {
    @State private var searchText: String = ""
    @EnvironmentObject var timezoneItems: TimezoneItems
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List(
                timezoneItems.timezones.filter {
                    searchText.isEmpty ? true : $0.lowercased().contains(searchText.lowercased())
                }
            ) { timezone in
                HStack {
                    Image(systemName: timezoneItems.selectedTimezones.contains(timezone) ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(timezoneItems.selectedTimezones.contains(timezone) ? .blue : .gray)
                    Text(timezone)
                }
                .contentShape(Rectangle())
                .onTapGesture { selectTimezone(timezone: timezone) }
            }
            .searchable(text: $searchText, prompt: "Search timezones")
            .navigationTitle("Select Timezones")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    func selectTimezone(timezone: String) {
        if timezoneItems.selectedTimezones.contains(timezone) {
            timezoneItems.selectedTimezones.remove(timezone)
        } else {
            timezoneItems.selectedTimezones.insert(timezone)
        }
    }
}

struct TimezoneDialog_Previews: PreviewProvider {
    static var previews: some View {
        TimezoneDialog().environmentObject(TimezoneItems())
    }
}
