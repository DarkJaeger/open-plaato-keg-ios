import SwiftUI

struct TransferListView: View {
    @EnvironmentObject var appState: AppState
    @State private var isRefreshing = false
    
    var body: some View {
        NavigationStack {
            ZStack {
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
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Transfer Scales")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                await refreshScales()
            }
        }
    }
    
    private func refreshScales() async {
        isRefreshing = true
        do {
            let scales = try await APIService.shared.fetchTransferScales()
            var fullScales: [TransferScale] = []
            for scale in scales {
                if let fullScale = try? await APIService.shared.fetchTransferScale(scale.id) {
                    fullScales.append(fullScale)
                } else {
                    fullScales.append(scale)
                }
            }
            appState.transferScales = fullScales
        } catch {
            appState.errorMessage = error.localizedDescription
        }
        isRefreshing = false
    }
}

#Preview {
    TransferListView()
        .environmentObject(AppState())
}
