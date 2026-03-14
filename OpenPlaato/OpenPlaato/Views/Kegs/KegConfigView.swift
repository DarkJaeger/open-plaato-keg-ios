import SwiftUI

struct KegConfigView: View {
    @EnvironmentObject var appState: AppState
    @State var keg: Keg
    @State private var isBusy = false
    @State private var alertTitle = ""
    @State private var alertMsg = ""
    @State private var showAlert = false

    @State private var emptyWeightInput = ""
    @State private var maxVolumeInput = ""
    @State private var knownWeightInput = ""
    @State private var tempOffsetInput = ""
    @State private var labelInput = ""
    @State private var refreshTimer: Timer?

    private let api = APIService.shared

    var body: some View {
        Form {
            liveReadingsSection
            labelSection
            unitSection
            modeSection
            sensitivitySection
            calibrationSection
            actionsSection
        }
        .navigationTitle("Scale Config")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { startPolling() }
        .onDisappear { stopPolling() }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: { Text(alertMsg) }
    }

    // MARK: - Sections

    private var liveReadingsSection: some View {
        Section("Live Readings") {
            LabeledContent("Level", value: keg.percentFormatted)
            LabeledContent(keg.measureUnit == "1" ? "Weight" : "Volume", value: keg.amountFormatted)
            LabeledContent("Temperature", value: keg.tempFormatted)
            LabeledContent("Pouring", value: keg.isPouringBool ? "Yes" : "No")
            if let raw = keg.weightRaw, let rawVal = Double(raw), rawVal > -1000, rawVal < 500 {
                LabeledContent("Raw Weight", value: String(format: "%.2f kg", rawVal))
            }
            if let fw = keg.firmwareVersion, !fw.isEmpty {
                LabeledContent("Firmware", value: fw)
            }
            if let wifi = keg.wifiSignalStrength, !wifi.isEmpty {
                LabeledContent("WiFi Signal", value: "\(wifi)%")
            }
        }
    }

    private var labelSection: some View {
        Section("Label") {
            HStack {
                TextField("Keg Label", text: $labelInput)
                Button("Set") {
                    run { try await api.setLabel(keg.id, value: labelInput) }
                }
                .disabled(labelInput.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .onAppear { labelInput = keg.myLabel ?? "" }
    }

    private var unitSection: some View {
        Section("Units") {
            let currentUnit = keg.unit ?? "1"
            Picker("Unit System", selection: binding(for: currentUnit, setter: { val in
                run { try await api.setUnit(keg.id, value: val) }
            })) {
                Text("Metric").tag("1")
                Text("US").tag("2")
            }
            .pickerStyle(.segmented)

            let currentMeasure = keg.measureUnit ?? "2"
            Picker("Measure", selection: binding(for: currentMeasure, setter: { val in
                run { try await api.setMeasureUnit(keg.id, value: val) }
            })) {
                Text("Weight").tag("1")
                Text("Volume").tag("2")
            }
            .pickerStyle(.segmented)
        }
    }

    private var modeSection: some View {
        Section("Keg Mode") {
            let currentMode = keg.kegMode ?? "1"
            Picker("Mode", selection: binding(for: currentMode, setter: { val in
                run { try await api.setKegMode(keg.id, value: val) }
            })) {
                Text("Beer").tag("1")
                Text("CO2").tag("2")
            }
            .pickerStyle(.segmented)
        }
    }

    private var sensitivitySection: some View {
        Section("Pour Sensitivity") {
            let currentSens = keg.sensitivity ?? "3"
            Picker("Sensitivity", selection: binding(for: currentSens, setter: { val in
                run { try await api.setSensitivity(keg.id, value: val) }
            })) {
                Text("Very Low").tag("1")
                Text("Low").tag("2")
                Text("Medium").tag("3")
                Text("High").tag("4")
            }
            .pickerStyle(.segmented)
        }
    }

    private var calibrationSection: some View {
        Section("Calibration") {
            HStack {
                TextField("Empty Keg Weight (kg)", text: $emptyWeightInput)
                    .keyboardType(.decimalPad)
                Button("Set") {
                    run { try await api.setEmptyKegWeight(keg.id, value: emptyWeightInput) }
                }
                .disabled(emptyWeightInput.isEmpty)
            }

            HStack {
                TextField("Max Keg Volume", text: $maxVolumeInput)
                    .keyboardType(.decimalPad)
                Button("Set") {
                    run { try await api.setMaxKegVolume(keg.id, value: maxVolumeInput) }
                }
                .disabled(maxVolumeInput.isEmpty)
            }

            HStack {
                TextField("Known Weight (kg)", text: $knownWeightInput)
                    .keyboardType(.decimalPad)
                Button("Calibrate") {
                    run { try await api.calibrateKnownWeight(keg.id, value: knownWeightInput) }
                }
                .disabled(knownWeightInput.isEmpty)
            }

            HStack {
                TextField("Temp Offset (°C)", text: $tempOffsetInput)
                    .keyboardType(.decimalPad)
                Button("Set") {
                    run { try await api.setTemperatureOffset(keg.id, value: tempOffsetInput) }
                }
                .disabled(tempOffsetInput.isEmpty)
            }
        }
        .onAppear {
            emptyWeightInput = keg.emptyKegWeight ?? ""
            maxVolumeInput = keg.maxKegVolume ?? ""
            tempOffsetInput = keg.temperatureOffset ?? ""
        }
    }

    private var actionsSection: some View {
        Section("Actions") {
            Button("Tare Scale") {
                run {
                    try await api.tare(keg.id)
                    try await Task.sleep(nanoseconds: 3_000_000_000)
                    try await api.tareRelease(keg.id)
                }
            }

            Button("Set Empty Keg (place empty keg on scale)") {
                run {
                    try await api.emptyKeg(keg.id)
                    try await Task.sleep(nanoseconds: 3_000_000_000)
                    try await api.emptyKegRelease(keg.id)
                }
            }

            Button("Reset Last Pour") {
                run { try await api.resetLastPour(keg.id) }
            }
        }
        .disabled(isBusy)
    }

    // MARK: - Helpers

    private func binding(for current: String, setter: @escaping (String) -> Void) -> Binding<String> {
        Binding(
            get: { current },
            set: { setter($0) }
        )
    }

    private func run(_ action: @escaping () async throws -> Void) {
        isBusy = true
        Task {
            do {
                try await action()
                await refreshKeg()
            } catch {
                alertTitle = "Error"
                alertMsg = error.localizedDescription
                showAlert = true
            }
            isBusy = false
        }
    }

    private func refreshKeg() async {
        do {
            keg = try await api.fetchKeg(keg.id)
        } catch {}
    }

    private func startPolling() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            Task { await refreshKeg() }
        }
    }

    private func stopPolling() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
}
