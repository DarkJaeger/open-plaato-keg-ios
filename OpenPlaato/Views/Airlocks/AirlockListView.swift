import SwiftUI

struct AirlockListView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            List(appState.airlocks) { airlock in
                VStack(alignment: .leading, spacing: 6) {
                    Text(airlock.name ?? airlock.deviceId).font(.headline)
                    HStack {
                        Label(airlock.gravityFormatted, systemImage: "scalemass.fill")
                        Spacer()
                        Label(airlock.tempFormatted, systemImage: "thermometer")
                        if let bat = airlock.battery {
                            Spacer()
                            Label("\(bat)%", systemImage: bat > 20 ? "battery.75" : "battery.25")
                                .foregroundColor(bat > 20 ? .primary : .red)
                        }
                    }
                    .font(.subheadline).foregroundColor(.secondary)
                }
                .padding(.vertical, 2)
            }
            .refreshable { await appState.loadAll() }
            .navigationTitle("Airlocks")
            .overlay {
                if appState.airlocks.isEmpty && !appState.isLoading {
                    VStack(spacing: 12) {
                        Image(systemName: "wind")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("No Airlocks")
                            .font(.headline)
                        Text("No PLAATO airlocks found")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}
