import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        TabView {
            ForEach(appState.tabOrder) { tab in
                tabView(for: tab)
                    .tabItem { Label(tab.title, systemImage: tab.systemImage) }
            }
        }
        .id(appState.tabOrder.map(\.rawValue).joined(separator: ","))
        .tint(.amber500)
    }

    @ViewBuilder
    private func tabView(for tab: AppTab) -> some View {
        switch tab {
        case .taps:
            TapListView()
        case .kegs:
            KegListView()
        case .airlocks:
            AirlockListView()
        case .transfers:
            TransferListView()
        case .beers:
            BeverageListView()
        case .settings:
            SettingsView()
        }
    }
}
