import SwiftUI

struct BeverageListView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            List(appState.beers) { beer in
                VStack(alignment: .leading, spacing: 4) {
                    Text(beer.name).font(.headline)
                    HStack {
                        if let style = beer.style {
                            Text(style).font(.subheadline).foregroundColor(.secondary)
                        }
                        Spacer()
                        if let abv = beer.abv {
                            Text(String(format: "%.1f%% ABV", abv))
                                .font(.caption).foregroundColor(.secondary)
                        }
                        if let ibu = beer.ibu {
                            Text("\(ibu) IBU")
                                .font(.caption).foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 2)
            }
            .refreshable { await appState.loadAll() }
            .navigationTitle("Beverages")
        }
    }
}
