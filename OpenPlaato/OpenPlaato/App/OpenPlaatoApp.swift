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
        let amber = UIColor(red: 245.0/255, green: 158.0/255, blue: 11.0/255, alpha: 1)
        let darkBg = UIColor(red: 15.0/255, green: 15.0/255, blue: 15.0/255, alpha: 1)
        let surface = UIColor(red: 26.0/255, green: 26.0/255, blue: 26.0/255, alpha: 1)
        let onSurface = UIColor(red: 229.0/255, green: 229.0/255, blue: 229.0/255, alpha: 1)
        let muted = UIColor(red: 156.0/255, green: 163.0/255, blue: 175.0/255, alpha: 1)

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
        let normalAttrs: [NSAttributedString.Key: Any] = [.foregroundColor: muted]
        let selectedAttrs: [NSAttributedString.Key: Any] = [.foregroundColor: amber]
        tabAppearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttrs
        tabAppearance.stackedLayoutAppearance.normal.iconColor = muted
        tabAppearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttrs
        tabAppearance.stackedLayoutAppearance.selected.iconColor = amber
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance

        // Table/List background
        UITableView.appearance().backgroundColor = darkBg
        UITableViewCell.appearance().backgroundColor = surface
    }
}
