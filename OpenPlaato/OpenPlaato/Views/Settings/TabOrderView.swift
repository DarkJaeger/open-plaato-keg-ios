import SwiftUI

struct TabOrderView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.editMode) private var editMode

    var body: some View {
        List {
            Section("Drag to reorder") {
                ForEach(appState.tabOrder) { tab in
                    Label(tab.title, systemImage: tab.systemImage)
                }
                .onMove(perform: appState.moveTab)
            }
        }
        .navigationTitle("Tab Order")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                EditButton()
            }
            ToolbarItem(placement: .topBarLeading) {
                Button("Reset") {
                    appState.resetTabOrder()
                }
                .disabled(appState.tabOrder == AppTab.allCases)
            }
        }
    }
}
