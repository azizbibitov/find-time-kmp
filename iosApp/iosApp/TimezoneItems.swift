import SwiftUI
import SharedLogic

class TimezoneItems: ObservableObject {
    @Published var timezones: [String] = []
    @Published var selectedTimezones = Set<String>()

    init() {
        self.timezones = TimeZoneHelperImpl().getTimeZoneStrings()
    }
}
