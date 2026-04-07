import SwiftUI

struct TransferListView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            Group {
                if appState.transferScales.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "scale.3d")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("No Transfer Scales Connected")
                            .font(.headline)
                        Text("Connect a transfer scale to get started")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(appState.transferScales) { scale in
                            NavigationLink(destination: TransferScaleConfigView(scale: scale)) {
                                TransferScaleCard(scale: scale)
                            }
                            .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                            .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Transfer Scales")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                await appState.refreshTransferScales()
            }
        }
    }
}
