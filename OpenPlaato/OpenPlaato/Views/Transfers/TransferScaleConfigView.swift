import SwiftUI

struct TransferScaleConfigView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    let scale: TransferScale

    @State private var label: String = ""
    @State private var emptyKegWeight: String = ""
    @State private var targetWeight: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showDeleteConfirmation = false
    @State private var showKegPicker = false
    @State private var successMessage: String?

    var body: some View {
        Form {
            Section("Scale Information") {
                HStack {
                    Text("Scale ID")
                    Spacer()
                    Text(scale.id.prefix(8).uppercased())
                        .foregroundColor(.secondary)
                        .font(.caption)
                }

                TextField("Label (optional)", text: $label)
            }

            Section("Configuration") {
                HStack {
                    Text("Empty Keg Weight (kg)")
                    Spacer()
                    TextField("kg", text: $emptyKegWeight)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                }

                HStack {
                    Text("Target Weight (kg)")
                    Spacer()
                    TextField("kg", text: $targetWeight)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                }

                Button(action: { showKegPicker = true }) {
                    Label("Auto-fill from Keg", systemImage: "arrow.down.doc")
                }
            }

            Section("Actions") {
                Button(action: saveConfiguration) {
                    HStack {
                        if isLoading {
                            ProgressView().tint(.blue)
                            Text("Saving...")
                        } else {
                            Label("Save Configuration", systemImage: "checkmark.circle")
                        }
                    }
                }
                .disabled(isLoading)

                Button(role: .destructive, action: { showDeleteConfirmation = true }) {
                    Label("Delete Scale", systemImage: "trash")
                }
            }

            if let error = errorMessage {
                Section {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }

            if let success = successMessage {
                Section {
                    Label(success, systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                }
            }
        }
        .navigationTitle(scale.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            label = scale.label ?? ""
            emptyKegWeight = scale.empty_keg_weight.map { String(format: "%.2f", $0) } ?? ""
            targetWeight = scale.target_weight.map { String(format: "%.2f", $0) } ?? ""
        }
        .sheet(isPresented: $showKegPicker) {
            KegPickerSheet(kegs: appState.kegs) { keg in
                if let weight = keg.emptyKegWeight {
                    emptyKegWeight = String(format: "%.2f", Double(weight) ?? 0)
                }
                showKegPicker = false
            }
        }
        .alert("Delete Scale", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive, action: deleteScale)
        } message: {
            Text("Are you sure you want to delete this transfer scale?")
        }
    }

    private func saveConfiguration() {
        isLoading = true
        errorMessage = nil
        successMessage = nil

        Task {
            do {
                let config = TransferScaleConfigBody(
                    label: label.isEmpty ? nil : label,
                    emptyKegWeight: Double(emptyKegWeight),
                    targetWeight: Double(targetWeight)
                )
                try await APIService.shared.configureTransferScale(scale.id, body: config)
                await appState.refreshTransferScales()
                successMessage = "Configuration saved"
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    dismiss()
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    private func deleteScale() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                try await APIService.shared.deleteTransferScale(scale.id)
                await appState.refreshTransferScales()
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

private struct KegPickerSheet: View {
    @Environment(\.dismiss) private var dismiss

    let kegs: [Keg]
    let onSelect: (Keg) -> Void

    var body: some View {
        NavigationStack {
            List(kegs) { keg in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(keg.name)
                            .font(.headline)
                        if let weight = keg.emptyKegWeight {
                            Text(String(format: "%.2f kg", Double(weight) ?? 0))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .foregroundColor(.blue)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    onSelect(keg)
                }
            }
            .navigationTitle("Select Keg")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
