import SwiftUI

@main
struct OpenPlaatoApp: App {
    @StateObject private var appState = AppState()

    init() {
        configureAppearance()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .preferredColorScheme(.dark)
                .task { await appState.loadAll() }
        }
    }

    private func configureAppearance() {
        let amber = UIColor(red: 0xF5/255, green: 0x9E/255, blue: 0x0B/255, alpha: 1)
        let darkBg = UIColor(red: 0x0F/255, green: 0x0F/255, blue: 0x0F/255, alpha: 1)
        let surface = UIColor(red: 0x1A/255, green: 0x1A/255, blue: 0x1A/255, alpha: 1)
        let onSurface = UIColor(red: 0xE5/255, green: 0xE5/255, blue: 0xE5/255, alpha: 1)

        // Navigation bar
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = darkBg
        navAppearance.titleTextAttributes = [.foregroundColor: onSurface]
        navAppearance.largeTitleTextAttributes = [.foregroundColor: onSurface]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
        UINavigationBar.appearance().tintColor = amber

        // Tab bar
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = darkBg
        let normalAttrs: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor(red: 0x9C/255, green: 0xA3/255, blue: 0xAF/255, alpha: 1)]
        let selectedAttrs: [NSAttributedString.Key: Any] = [.foregroundColor: amber]
        tabAppearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttrs
        tabAppearance.stackedLayoutAppearance.normal.iconColor = UIColor(red: 0x9C/255, green: 0xA3/255, blue: 0xAF/255, alpha: 1)
        tabAppearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttrs
        tabAppearance.stackedLayoutAppearance.selected.iconColor = amber
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance

        // Table/List background
        UITableView.appearance().backgroundColor = UIColor(red: 0x0F/255, green: 0x0F/255, blue: 0x0F/255, alpha: 1)
        UITableViewCell.appearance().backgroundColor = surface
    }
}
