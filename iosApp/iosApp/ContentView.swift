import SwiftUI
import SharedLogic

struct ContentView: View {
    @StateObject private var timezoneItems = TimezoneItems()
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
        .tint(.white)
        .environmentObject(timezoneItems)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
