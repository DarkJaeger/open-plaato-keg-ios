import SwiftUI

struct AirlockListView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            List(appState.airlocks) { airlock in
                NavigationLink(destination: AirlockDetailView(airlock: airlock)) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(airlock.displayName).font(.headline)
                        HStack {
                            Label(airlock.gravityFormatted, systemImage: "scalemass.fill")
                            Spacer()
                            Label(airlock.tempFormatted, systemImage: "thermometer")
                            Spacer()
                            Label(airlock.bubblesFormatted, systemImage: "bubble.left.fill")
                        }
                        .font(.subheadline).foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 2)
                }
            }
            .refreshable { await appState.loadAll() }
            .navigationTitle("Airlocks")
            .overlay {
                if appState.airlocks.isEmpty && !appState.isLoading {
                    VStack(spacing: 12) {
                        Image(systemName: "wind")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        Text("No Airlocks")
                            .font(.headline)
                        Text("No PLAATO airlocks found")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}
