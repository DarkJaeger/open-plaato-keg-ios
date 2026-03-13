import SwiftUI

struct TapListView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTap: Tap?

    var body: some View {
        NavigationStack {
            Group {
                if appState.isLoading && appState.taps.isEmpty {
                    ProgressView("Loading taps...")
                } else if appState.taps.isEmpty {
                    ContentUnavailableView("No Taps", systemImage: "drop.fill",
                                          description: Text("Add taps via the web UI"))
                } else {
                    List(appState.taps) { tap in
                        NavigationLink(destination: TapEditView(tap: tap)) {
                            TapRowView(
                                tap: tap,
                                keg: appState.keg(for: tap),
                                beer: appState.keg(for: tap).flatMap { appState.beer(for: $0) }
                            )
                        }
                    }
                    .refreshable { await appState.loadAll() }
                }
            }
            .navigationTitle("Taps")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { Task { await appState.loadAll() } } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .alert("Error", isPresented: .constant(appState.errorMessage != nil)) {
                Button("OK") { appState.errorMessage = nil }
            } message: {
                Text(appState.errorMessage ?? "")
            }
        }
    }
}
