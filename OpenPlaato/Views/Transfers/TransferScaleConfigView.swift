import SwiftUI

struct TransferScaleConfigView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
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
        NavigationStack {
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
                        HStack {
                            Image(systemName: "arrow.down.doc")
                            Text("Auto-fill from Keg")
                        }
                    }
                    .foregroundColor(.blue)
                }
                
                Section("Actions") {
                    Button(action: saveConfiguration) {
                        if isLoading {
                            HStack {
                                ProgressView()
                                    .tint(.blue)
                                Spacer()
                                Text("Saving...")
                            }
                        } else {
                            HStack {
                                Image(systemName: "checkmark.circle")
                                Text("Save Configuration")
                                Spacer()
                            }
                        }
                    }
                    .foregroundColor(.blue)
                    .disabled(isLoading)
                    
                    Button(role: .destructive, action: { showDeleteConfirmation = true }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Scale")
                        }
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
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(success)
                                .foregroundColor(.green)
                        }
                        .font(.caption)
                    }
                }
            }
            .navigationTitle(scale.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                label = scale.label ?? ""
                emptyKegWeight = scale.empty_keg_weight.map(String.init) ?? ""
                targetWeight = scale.target_weight.map(String.init) ?? ""
            }
            .sheet(isPresented: $showKegPicker) {
                KegPickerSheet(
                    kegs: appState.kegs,
                    onSelect: { keg in
                        if let weight = keg.emptyKegWeight {
                            emptyKegWeight = String(format: "%.2f", Double(weight) ?? 0)
                        }
                        showKegPicker = false
                    }
                )
            }
            .alert("Delete Scale", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive, action: deleteScale)
            } message: {
                Text("Are you sure you want to delete this transfer scale?")
            }
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
                
                // Update local state
                if let idx = appState.transferScales.firstIndex(where: { $0.id == scale.id }) {
                    appState.transferScales[idx].label = config.label
                    appState.transferScales[idx].empty_keg_weight = config.empty_keg_weight
                    appState.transferScales[idx].target_weight = config.target_weight
                }
                
                successMessage = "Configuration saved"
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
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
                appState.transferScales.removeAll { $0.id == scale.id }
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

struct KegPickerSheet: View {
    @Environment(\.dismiss) var dismiss
    
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

#Preview {
    let scale = TransferScale(
        id: "scale-123",
        label: "Transfer Scale 1",
        raw_weight: 24.50,
        empty_keg_weight: 10.0,
        target_weight: 40.0,
        fill_percent: 72.5,
        last_updated: nil
    )
    
    TransferScaleConfigView(scale: scale)
        .environmentObject(AppState())
}
