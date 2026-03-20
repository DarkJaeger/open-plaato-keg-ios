import SwiftUI

struct KegListView: View {
    @EnvironmentObject var appState: AppState
    @State private var isEditing = false

    private var orderedKegs: [Keg] {
        appState.orderedKegs
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(orderedKegs) { keg in
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
                .onMove { from, to in
                    appState.moveKeg(from: from, to: to)
                }
            }
            .refreshable { await appState.loadAll() }
            .navigationTitle("Kegs")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isEditing ? "Done" : "Reorder") {
                        withAnimation { isEditing.toggle() }
                    }
                    .disabled(orderedKegs.count < 2)
                }
            }
            .environment(\.editMode, .constant(isEditing ? .active : .inactive))
        }
    }
}
