import Foundation

@MainActor
class AppState: ObservableObject {
    @Published var taps: [Tap] = []
    @Published var kegs: [Keg] = []
    @Published var beers: [Beer] = []
    @Published var airlocks: [Airlock] = []
    @Published var transferScales: [TransferScale] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let api = APIService.shared
    private let ws  = WebSocketService.shared

    init() {
        ws.onKegUpdate = { [weak self] updatedKeg in
            guard let self else { return }
            if let idx = self.kegs.firstIndex(where: { $0.id == updatedKeg.id }) {
                self.kegs[idx] = updatedKeg
            }
        }
        ws.onAirlockUpdate = { [weak self] updatedAirlock in
            guard let self else { return }
            if let idx = self.airlocks.firstIndex(where: { $0.id == updatedAirlock.id }) {
                self.airlocks[idx] = updatedAirlock
            } else {
                self.airlocks.append(updatedAirlock)
            }
        }
        ws.onTransferScaleUpdate = { [weak self] updatedScale in
            guard let self else { return }
            if let idx = self.transferScales.firstIndex(where: { $0.id == updatedScale.id }) {
                var existing = self.transferScales[idx]
                existing.raw_weight = updatedScale.raw_weight
                existing.fill_percent = updatedScale.fill_percent
                existing.last_updated = updatedScale.last_updated
                self.transferScales[idx] = existing
            }
        }
        ws.connect()
    }

    func loadAll() async {
        isLoading = true
        defer { isLoading = false }
        do {
            async let t = api.fetchTaps()
            async let k = api.fetchKegs()
            async let b = api.fetchBeers()
            async let a = api.fetchAirlocks()
            async let ts = api.fetchTransferScales()
            (taps, kegs, beers, airlocks, transferScales) = try await (t, k, b, a, ts)
            
            // Fetch full details for each transfer scale
            var fullScales: [TransferScale] = []
            for scale in transferScales {
                if let fullScale = try? await api.fetchTransferScale(scale.id) {
                    fullScales.append(fullScale)
                } else {
                    fullScales.append(scale)
                }
            }
            self.transferScales = fullScales
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func keg(for tap: Tap) -> Keg? {
        guard let id = tap.kegId else { return nil }
        return kegs.first { $0.id == id }
    }

    func beer(for keg: Keg) -> Beer? {
        guard let style = keg.myBeerStyle, !style.isEmpty else { return nil }
        return beers.first { $0.name.localizedCaseInsensitiveCompare(style) == .orderedSame }
    }
}
