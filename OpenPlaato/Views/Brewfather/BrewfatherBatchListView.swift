import SwiftUI

struct BrewfatherBatchListView: View {
    @EnvironmentObject var appState: AppState
    @State private var batches: [BrewfatherBatch] = []
    @State private var isLoading = true
    @State private var errorMsg: String?
    @State private var importingId: String?
    @State private var importSuccess: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading Brewfather batches...")
                } else if let err = errorMsg {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48)).foregroundColor(.orange)
                        Text("Failed to load batches").font(.headline)
                        Text(err).font(.subheadline).foregroundColor(.secondary)
                            .multilineTextAlignment(.center).padding(.horizontal)
                        Button("Retry") { loadBatches() }
                    }
                } else if batches.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.system(size: 48)).foregroundColor(.secondary)
                        Text("No Batches").font(.headline)
                        Text("No batches found in your Brewfather account")
                            .font(.subheadline).foregroundColor(.secondary)
                    }
                } else {
                    List(batches) { batch in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(batch.name).font(.headline)
                                HStack {
                                    Text(batch.style)
                                        .font(.subheadline).foregroundColor(.secondary)
                                    if let abv = batch.abv {
                                        Text(String(format: "%.1f%% ABV", abv))
                                            .font(.caption).foregroundColor(.secondary)
                                    }
                                }
                                Text(batch.status.capitalized)
                                    .font(.caption2)
                                    .padding(.horizontal, 8).padding(.vertical, 2)
                                    .background(Color.accentColor.opacity(0.15))
                                    .clipShape(Capsule())
                            }
                            Spacer()
                            if importingId == batch.id {
                                ProgressView()
                            } else {
                                Button {
                                    importBatch(batch.id)
                                } label: {
                                    Image(systemName: "square.and.arrow.down")
                                }
                                .buttonStyle(.borderless)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
            .navigationTitle("Brewfather Batches")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Imported", isPresented: .constant(importSuccess != nil)) {
                Button("OK") { importSuccess = nil }
            } message: { Text(importSuccess ?? "") }
            .task { loadBatches() }
        }
    }

    private func loadBatches() {
        isLoading = true
        errorMsg = nil
        Task {
            do {
                batches = try await APIService.shared.fetchBrewfatherBatches()
            } catch {
                errorMsg = error.localizedDescription
            }
            isLoading = false
        }
    }

    private func importBatch(_ id: String) {
        importingId = id
        Task {
            do {
                try await APIService.shared.importBrewfatherBatch(id)
                await appState.loadAll()
                importSuccess = "Batch imported as beverage successfully."
            } catch {
                errorMsg = error.localizedDescription
            }
            importingId = nil
        }
    }
}
