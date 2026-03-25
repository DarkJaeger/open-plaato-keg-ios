import SwiftUI

struct BeverageListView: View {
    @EnvironmentObject var appState: AppState
    @State private var showCreateBeverage = false

    var body: some View {
        NavigationStack {
            Group {
                if appState.beers.isEmpty && !appState.isLoading {
                    VStack(spacing: 12) {
                        Image(systemName: "mug.fill")
                            .font(.system(size: 48)).foregroundColor(.secondary)
                        Text("No Beverages").font(.headline)
                        Text("Tap + to add a beverage")
                            .font(.subheadline).foregroundColor(.secondary)
                    }
                } else {
                    List(appState.beers) { beer in
                        NavigationLink(destination: BeverageEditView(beer: beer)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(beer.name).font(.headline)
                                HStack {
                                    if let style = beer.style, !style.isEmpty {
                                        Text(style).font(.subheadline).foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    if !beer.abvFormatted.isEmpty {
                                        Text(beer.abvFormatted)
                                            .font(.caption).foregroundColor(.secondary)
                                    }
                                    if !beer.ibuFormatted.isEmpty {
                                        Text(beer.ibuFormatted)
                                            .font(.caption).foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(.vertical, 2)
                        }
                    }
                    .refreshable { await appState.loadAll() }
                }
            }
            .navigationTitle("Beverages")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showCreateBeverage = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreateBeverage) {
                NavigationStack {
                    BeverageEditView(beer: Beer(
                        id: UUID().uuidString.lowercased().replacingOccurrences(of: "-", with: ""),
                        name: ""
                    ))
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") { showCreateBeverage = false }
                        }
                    }
                }
                .environmentObject(appState)
            }
        }
    }
}
