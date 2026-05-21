import SwiftUI
import UIKit

@main
struct iOSApp: App {
    init() {
        if #unavailable(iOS 26.0) {
            let tabBarItemAppearance = UITabBarItemAppearance()
            tabBarItemAppearance.configureWithDefault(for: .stacked)
            tabBarItemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.black]
            tabBarItemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]
            tabBarItemAppearance.normal.iconColor = .black
            tabBarItemAppearance.selected.iconColor = .white

            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.stackedLayoutAppearance = tabBarItemAppearance
            appearance.backgroundColor = .systemBlue

            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
