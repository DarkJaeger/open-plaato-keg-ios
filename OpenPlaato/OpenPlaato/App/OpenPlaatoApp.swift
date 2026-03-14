import SwiftUI

@main
struct OpenPlaatoApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .task { await appState.loadAll() }
        }
    }
}
