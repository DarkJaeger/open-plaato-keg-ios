import SwiftUI

struct TapEditView: View {
    @EnvironmentObject var appState: AppState
    @State var tap: Tap
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var isSaving = false
    @State private var saveError: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("Tap Info") {
                TextField("Name", text: $tap.name)
                Picker("Keg", selection: $tap.kegId) {
                    Text("None").tag(Int?.none)
                    ForEach(appState.kegs) { keg in
                        Text(keg.name).tag(Optional(keg.id))
                    }
                }
            }

            Section("Handle Image") {
                if let img = selectedImage {
                    Image(uiImage: img)
                        .resizable().scaledToFit()
                        .frame(maxHeight: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else if let url = tap.handleImageUrl, let imageURL = URL(string: url) {
                    AsyncImage(url: imageURL) { image in
                        image.resizable().scaledToFit()
                            .frame(maxHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } placeholder: { ProgressView() }
                }
                Button("Choose Photo") { showImagePicker = true }
            }
        }
        .navigationTitle(tap.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") { save() }
                    .disabled(isSaving)
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePickerView(selectedImage: $selectedImage)
        }
        .alert("Save Failed", isPresented: .constant(saveError != nil)) {
            Button("OK") { saveError = nil }
        } message: { Text(saveError ?? "") }
    }

    private func save() {
        isSaving = true
        Task {
            do {
                if let img = selectedImage, let data = img.jpegData(compressionQuality: 0.8) {
                    let url = try await APIService.shared.uploadHandleImage(data, tapId: tap.id)
                    tap.handleImageUrl = url
                }
                try await APIService.shared.updateTap(tap)
                await appState.loadAll()
                dismiss()
            } catch {
                saveError = error.localizedDescription
            }
            isSaving = false
        }
    }
}
