import SwiftUI

struct TapEditView: View {
    @EnvironmentObject var appState: AppState
    @State var tap: Tap
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var showTapHandlePicker = false
    @State private var isSaving = false
    @State private var saveError: String?
    @State private var showDeleteConfirm = false
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var brewery: String = ""
    @State private var style: String = ""
    @State private var abv: String = ""
    @State private var ibu: String = ""
    @State private var color: String = "#c9a849"
    @State private var beerDescription: String = ""
    @State private var tastingNotes: String = ""
    @State private var kegId: String?
    @State private var deviceId: String = ""
    @State private var handleImage: String?

    var body: some View {
        Form {
            Section("Tap Info") {
                TextField("Name", text: $name)
                TextField("Device ID (6 chars max)", text: $deviceId)
                    .autocapitalization(.none)
                    .onChange(of: deviceId) { val in
                        if val.count > 6 { deviceId = String(val.prefix(6)) }
                    }
                Picker("Keg", selection: $kegId) {
                    Text("None").tag(String?.none)
                    ForEach(appState.kegs) { keg in
                        Text(keg.name).tag(Optional(keg.id))
                    }
                }
            }

            Section("Beer Details") {
                TextField("Brewery", text: $brewery)
                TextField("Style", text: $style)
                HStack {
                    TextField("ABV", text: $abv).keyboardType(.decimalPad)
                    TextField("IBU", text: $ibu).keyboardType(.decimalPad)
                }
                TextField("Description", text: $beerDescription, axis: .vertical)
                    .lineLimit(3...6)
                TextField("Tasting Notes", text: $tastingNotes, axis: .vertical)
                    .lineLimit(2...4)
            }

            Section("Color") {
                ColorPicker("Beer Color", selection: colorBinding)
            }

            beverageAutoFillSection

            Section("Handle Image") {
                if let img = selectedImage {
                    Image(uiImage: img)
                        .resizable().scaledToFit()
                        .frame(maxHeight: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else if let url = imageUrl, let imageURL = URL(string: url) {
                    AsyncImage(url: imageURL) { image in
                        image.resizable().scaledToFit()
                            .frame(maxHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } placeholder: { ProgressView() }
                }
                Button("Choose from Gallery") { showImagePicker = true }
                Button("Choose from Server") { showTapHandlePicker = true }
            }

            Section {
                Button("Delete Tap", role: .destructive) {
                    showDeleteConfirm = true
                }
            }
        }
        .navigationTitle(tap.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") { save() }.disabled(isSaving)
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePickerView(selectedImage: $selectedImage)
        }
        .sheet(isPresented: $showTapHandlePicker) {
            TapHandlePickerView(selectedFilename: $handleImage)
        }
        .alert("Save Failed", isPresented: .constant(saveError != nil)) {
            Button("OK") { saveError = nil }
        } message: { Text(saveError ?? "") }
        .confirmationDialog("Delete Tap?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) { deleteTap() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This tap will be permanently removed.")
        }
        .onAppear { populateFields() }
    }

    // MARK: - Beverage Auto-fill

    private var beverageAutoFillSection: some View {
        Section("Auto-fill from Beverage") {
            if appState.beers.isEmpty {
                Text("No beverages available").foregroundColor(.secondary)
            } else {
                ForEach(appState.beers) { beer in
                    Button {
                        fillFromBeverage(beer)
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(beer.name).foregroundColor(.primary)
                                if let s = beer.style, !s.isEmpty {
                                    Text(s).font(.caption).foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                            Image(systemName: "arrow.down.doc")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private var imageUrl: String? {
        guard let img = handleImage, !img.isEmpty else { return nil }
        let base = UserDefaults.standard.string(forKey: "serverURL") ?? "http://192.168.8.141:8085"
        return "\(base)/uploads/tap-handles/\(img)"
    }

    private var colorBinding: Binding<Color> {
        Binding(
            get: { Color(hex: color) ?? .orange },
            set: { color = $0.toHex() }
        )
    }

    private func populateFields() {
        name = tap.name
        brewery = tap.brewery ?? ""
        style = tap.style ?? ""
        abv = tap.abv ?? ""
        ibu = tap.ibu ?? ""
        color = tap.color ?? "#c9a849"
        beerDescription = tap.description ?? ""
        tastingNotes = tap.tastingNotes ?? ""
        kegId = tap.kegId
        deviceId = tap.deviceId ?? ""
        handleImage = tap.handleImage
    }

    private func fillFromBeverage(_ beer: Beer) {
        name = beer.name
        brewery = beer.brewery ?? ""
        style = beer.style ?? ""
        abv = beer.abv ?? ""
        ibu = beer.ibu ?? ""
        color = beer.color ?? "#c9a849"
        beerDescription = beer.description ?? ""
        tastingNotes = beer.tastingNotes ?? ""
    }

    private func save() {
        isSaving = true
        Task {
            do {
                if let img = selectedImage {
                    let resized = img.resizedTo(CGSize(width: 200, height: 200))
                    guard let data = resized.jpegData(compressionQuality: 0.85) else {
                        throw URLError(.cannotCreateFile)
                    }
                    let filename = try await APIService.shared.uploadHandleImage(data)
                    handleImage = filename
                }

                let body = TapSaveBody(
                    tapNumber: tap.tapNumber,
                    name: name,
                    brewery: brewery,
                    style: style,
                    abv: abv,
                    ibu: ibu,
                    color: color,
                    description: beerDescription,
                    tastingNotes: tastingNotes,
                    kegId: kegId,
                    handleImage: handleImage,
                    deviceId: deviceId.isEmpty ? nil : deviceId
                )

                try await APIService.shared.saveTap(tap.id, body: body)
                await appState.loadAll()
                dismiss()
            } catch {
                saveError = error.localizedDescription
            }
            isSaving = false
        }
    }

    private func deleteTap() {
        Task {
            do {
                try await APIService.shared.deleteTap(tap.id)
                await appState.loadAll()
                dismiss()
            } catch {
                saveError = error.localizedDescription
            }
        }
    }
}
