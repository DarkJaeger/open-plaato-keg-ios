import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TapListView()
                .tabItem { Label("Taps", systemImage: "drop.fill") }

            KegListView()
                .tabItem { Label("Kegs", systemImage: "cylinder.fill") }

            AirlockListView()
                .tabItem { Label("Airlocks", systemImage: "wind") }

            BeverageListView()
                .tabItem { Label("Beers", systemImage: "mug.fill") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .tint(.amber500)
    }
}
