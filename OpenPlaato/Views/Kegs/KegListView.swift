import SwiftUI

struct KegListView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            List(appState.kegs) { keg in
                NavigationLink(destination: KegDetailView(keg: keg)) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(keg.name).font(.headline)
                        HStack {
                            Label(keg.percentFormatted, systemImage: "cylinder.fill")
                            Spacer()
                            Label(keg.tempFormatted, systemImage: "thermometer")
                        }
                        .font(.subheadline).foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 2)
                }
            }
            .refreshable { await appState.loadAll() }
            .navigationTitle("Kegs")
        }
    }
}
