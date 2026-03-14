import SwiftUI

struct TapListView: View {
    @EnvironmentObject var appState: AppState
    @State private var showCreateTap = false

    var body: some View {
        NavigationStack {
            Group {
                if appState.isLoading && appState.taps.isEmpty {
                    ProgressView("Loading taps...")
                } else if appState.taps.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "drop.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("No Taps").font(.headline)
                        Text("Tap + to create a tap")
                            .font(.subheadline).foregroundColor(.secondary)
                    }
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
                    HStack(spacing: 16) {
                        Button { Task { await appState.loadAll() } } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                        Button { showCreateTap = true } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showCreateTap) {
                NavigationStack {
                    TapEditView(tap: Tap(
                        id: UUID().uuidString.lowercased().replacingOccurrences(of: "-", with: ""),
                        name: "New Tap"
                    ))
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") { showCreateTap = false }
                        }
                    }
                }
                .environmentObject(appState)
            }
            .alert("Error", isPresented: Binding(
                get: { appState.errorMessage != nil },
                set: { if !$0 { appState.errorMessage = nil } }
            )) {
                Button("OK") { appState.errorMessage = nil }
            } message: {
                Text(appState.errorMessage ?? "")
            }
        }
    }
}
