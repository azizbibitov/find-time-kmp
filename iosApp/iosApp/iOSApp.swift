import SwiftUI
import UIKit

@main
struct iOSApp: App {
    init() {
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
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
