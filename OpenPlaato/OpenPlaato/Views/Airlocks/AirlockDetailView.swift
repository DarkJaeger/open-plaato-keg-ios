import SwiftUI

struct AirlockDetailView: View {
    @EnvironmentObject var appState: AppState
    @State var airlock: Airlock
    @State private var labelInput: String = ""
    @State private var isSaving = false
    @State private var alertMsg: String?

    private let api = APIService.shared

    var body: some View {
        Form {
            Section("Status") {
                LabeledContent("Temperature", value: airlock.tempFormatted)
                LabeledContent("Bubbles/min", value: airlock.bubblesFormatted)
                LabeledContent("Specific Gravity", value: airlock.gravityFormatted)
            }

            Section("Label") {
                HStack {
                    TextField("Airlock Label", text: $labelInput)
                    Button("Set") {
                        save {
                            try await api.setAirlockLabel(airlock.id, value: labelInput)
                        }
                    }
                    .disabled(labelInput.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }

            grainfatherSection
            brewfatherSection
        }
        .navigationTitle(airlock.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: .constant(alertMsg != nil)) {
            Button("OK") { alertMsg = nil }
        } message: { Text(alertMsg ?? "") }
        .onAppear {
            labelInput = airlock.label ?? ""
            gfEnabled = airlock.isGrainfatherEnabled
            gfUnit = airlock.grainfatherUnit ?? "celsius"
            gfSg = airlock.grainfatherSpecificGravity ?? "1.0"
            gfUrl = airlock.grainfatherUrl ?? ""
            bfEnabled = airlock.isBrewfatherEnabled
            bfUnit = airlock.brewfatherTempUnit ?? "celsius"
            bfSg = airlock.brewfatherSg ?? "1.0"
            bfUrl = airlock.brewfatherUrl ?? ""
            bfOg = airlock.brewfatherOg ?? ""
            bfBatchVol = airlock.brewfatherBatchVolume ?? ""
        }
    }

    // MARK: - Grainfather

    @State private var gfEnabled = false
    @State private var gfUnit = "celsius"
    @State private var gfSg = "1.0"
    @State private var gfUrl = ""

    private var grainfatherSection: some View {
        Section("Grainfather") {
            Toggle("Enabled", isOn: $gfEnabled)
            if gfEnabled {
                Picker("Unit", selection: $gfUnit) {
                    Text("Celsius").tag("celsius")
                    Text("Fahrenheit").tag("fahrenheit")
                }
                TextField("Specific Gravity", text: $gfSg)
                    .keyboardType(.decimalPad)
                TextField("Webhook URL", text: $gfUrl)
                    .autocapitalization(.none)
                    .keyboardType(.URL)
                Button("Save Grainfather Settings") {
                    save {
                        try await api.setGrainfather(airlock.id, body: GrainfatherBody(
                            enabled: gfEnabled, unit: gfUnit, specificGravity: gfSg, url: gfUrl
                        ))
                    }
                }
                .disabled(isSaving)
            }
        }
    }

    // MARK: - Brewfather

    @State private var bfEnabled = false
    @State private var bfUnit = "celsius"
    @State private var bfSg = "1.0"
    @State private var bfUrl = ""
    @State private var bfOg = ""
    @State private var bfBatchVol = ""

    private var brewfatherSection: some View {
        Section("Brewfather") {
            Toggle("Enabled", isOn: $bfEnabled)
            if bfEnabled {
                Picker("Unit", selection: $bfUnit) {
                    Text("Celsius").tag("celsius")
                    Text("Fahrenheit").tag("fahrenheit")
                }
                TextField("Specific Gravity", text: $bfSg)
                    .keyboardType(.decimalPad)
                TextField("OG", text: $bfOg)
                    .keyboardType(.decimalPad)
                TextField("Batch Volume", text: $bfBatchVol)
                    .keyboardType(.decimalPad)
                TextField("Custom Stream URL", text: $bfUrl)
                    .autocapitalization(.none)
                    .keyboardType(.URL)
                Button("Save Brewfather Settings") {
                    save {
                        try await api.setBrewfather(airlock.id, body: BrewfatherBody(
                            enabled: bfEnabled, unit: bfUnit, specificGravity: bfSg,
                            url: bfUrl,
                            og: bfOg.isEmpty ? nil : bfOg,
                            batchVolume: bfBatchVol.isEmpty ? nil : bfBatchVol
                        ))
                    }
                }
                .disabled(isSaving)
            }
        }
    }

    // MARK: - Helpers

    private func save(_ action: @escaping () async throws -> Void) {
        isSaving = true
        Task {
            do {
                try await action()
                await reloadAirlock()
            } catch {
                alertMsg = error.localizedDescription
            }
            isSaving = false
        }
    }

    private func reloadAirlock() async {
        await appState.loadAll()
        if let updated = appState.airlocks.first(where: { $0.id == airlock.id }) {
            airlock = updated
        }
    }
}
