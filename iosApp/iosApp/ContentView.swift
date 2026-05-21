import SwiftUI
import SharedLogic

struct ContentView: View {
    @StateObject private var timezoneItems = TimezoneItems()

    private var tabTintColor: Color {
        if #available(iOS 26.0, *) {
            return .accentColor
        } else {
            return .white
        }
    }

    var body: some View {
        TabView {
            TimezoneView()
                .tabItem {
                    Label("Time Zones", systemImage: "network")
                }
            FindMeeting()
                .tabItem {
                    Label("Find Meeting", systemImage: "clock")
                }
        }
        .tint(tabTintColor)
        .environmentObject(timezoneItems)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
