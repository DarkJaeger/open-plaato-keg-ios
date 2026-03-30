import SwiftUI

struct TapHandlePickerView: View {
    @Binding var selectedFilename: String?
    @State private var handles: [TapHandleInfo] = []
    @State private var isLoading = true
    @Environment(\.dismiss) private var dismiss

    private var baseURL: String {
        let stored = UserDefaults.standard.string(forKey: "serverURL") ?? ""
        return stored.isEmpty ? "http://192.168.8.141:8085" : stored
    }

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading handles...")
                } else if handles.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 48)).foregroundColor(.secondary)
                        Text("No tap handles on server").foregroundColor(.secondary)
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 12)], spacing: 12) {
                            ForEach(handles, id: \.filename) { handle in
                                let url = URL(string: "\(baseURL)/uploads/tap-handles/\(handle.filename)")
                                Button {
                                    selectedFilename = handle.filename
                                    dismiss()
                                } label: {
                                    AsyncImage(url: url) { image in
                                        image.resizable().scaledToFill()
                                    } placeholder: {
                                        Color.gray.opacity(0.2)
                                    }
                                    .frame(width: 90, height: 90)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(handle.filename == selectedFilename ? Color.accentColor : Color.clear, lineWidth: 3)
                                    )
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Tap Handles")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .task {
                do {
                    handles = try await APIService.shared.fetchTapHandles()
                } catch {}
                isLoading = false
            }
        }
    }
}
