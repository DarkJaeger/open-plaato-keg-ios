import SwiftUI

struct BeverageEditView: View {
    @EnvironmentObject var appState: AppState
    let beer: Beer
    @State private var name: String = ""
    @State private var brewery: String = ""
    @State private var style: String = ""
    @State private var abv: String = ""
    @State private var ibu: String = ""
    @State private var og: String = ""
    @State private var fg: String = ""
    @State private var srm: String = ""
    @State private var color: String = "#c9a849"
    @State private var beerDescription: String = ""
    @State private var tastingNotes: String = ""
    @State private var isSaving = false
    @State private var saveError: String?
    @State private var showSaveError = false
    @State private var showDeleteConfirm = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("Basic Info") {
                TextField("Name", text: $name)
                TextField("Brewery", text: $brewery)
                TextField("Style", text: $style)
            }

            Section("Numbers") {
                HStack {
                    TextField("ABV", text: $abv).keyboardType(.decimalPad)
                    TextField("IBU", text: $ibu).keyboardType(.decimalPad)
                    TextField("SRM", text: $srm).keyboardType(.decimalPad)
                }
                HStack {
                    TextField("OG", text: $og).keyboardType(.decimalPad)
                    TextField("FG", text: $fg).keyboardType(.decimalPad)
                }
            }

            Section("Color") {
                ColorPicker("Beer Color", selection: colorBinding)
            }

            Section("Details") {
                TextField("Description", text: $beerDescription, axis: .vertical)
                    .lineLimit(3...6)
                TextField("Tasting Notes", text: $tastingNotes, axis: .vertical)
                    .lineLimit(2...4)
            }

            Section {
                Button("Delete Beverage", role: .destructive) {
                    showDeleteConfirm = true
                }
            }
        }
        .navigationTitle(beer.name.isEmpty ? "New Beverage" : beer.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") { save() }.disabled(isSaving || name.isEmpty)
            }
        }
        .alert("Save Failed", isPresented: $showSaveError) {
            Button("OK") {}
        } message: { Text(saveError ?? "") }
        .confirmationDialog("Delete Beverage?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) { deleteBeverage() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This beverage will be permanently removed.")
        }
        .onAppear { populateFields() }
    }

    private var colorBinding: Binding<Color> {
        Binding(
            get: { Color(hex: color) ?? .orange },
            set: { color = $0.toHex() }
        )
    }

    private func populateFields() {
        name = beer.name
        brewery = beer.brewery ?? ""
        style = beer.style ?? ""
        abv = beer.abv ?? ""
        ibu = beer.ibu ?? ""
        og = beer.og ?? ""
        fg = beer.fg ?? ""
        srm = beer.srm ?? ""
        color = beer.color ?? "#c9a849"
        beerDescription = beer.description ?? ""
        tastingNotes = beer.tastingNotes ?? ""
    }

    private func save() {
        isSaving = true
        Task {
            do {
                let body = BeverageSaveBody(
                    name: name, brewery: brewery, style: style,
                    abv: abv, ibu: ibu, color: color,
                    description: beerDescription, tastingNotes: tastingNotes,
                    og: og, fg: fg, srm: srm
                )
                try await APIService.shared.saveBeverage(beer.id, body: body)
                await appState.loadAll()
                dismiss()
            } catch {
                saveError = error.localizedDescription
                showSaveError = true
            }
            isSaving = false
        }
    }

    private func deleteBeverage() {
        Task {
            do {
                try await APIService.shared.deleteBeverage(beer.id)
                await appState.loadAll()
                dismiss()
            } catch {
                saveError = error.localizedDescription
                showSaveError = true
            }
        }
    }
}
