import Foundation

enum AppTab: String, CaseIterable, Identifiable {
    case taps
    case kegs
    case airlocks
    case transfers
    case beers
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .taps: return "Taps"
        case .kegs: return "Kegs"
        case .airlocks: return "Airlocks"
        case .transfers: return "Transfers"
        case .beers: return "Beers"
        case .settings: return "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .taps: return "drop.fill"
        case .kegs: return "cylinder.fill"
        case .airlocks: return "wind"
        case .transfers: return "scale.3d"
        case .beers: return "mug.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

@MainActor
class AppState: ObservableObject {
    @Published var taps: [Tap] = []
    @Published var kegs: [Keg] = []
    @Published var beers: [Beer] = []
    @Published var airlocks: [Airlock] = []
    @Published var transferScales: [TransferScale] = []
    @Published var tabOrder: [AppTab] = AppTab.allCases
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let api = APIService.shared
    private let ws  = WebSocketService.shared

    private let kegOrderKey = "kegOrder"
    private let tabOrderKey = "tabOrder"

    var orderedKegs: [Keg] {
        let savedOrder = UserDefaults.standard.stringArray(forKey: kegOrderKey) ?? []
        guard !savedOrder.isEmpty else { return kegs }
        let lookup = Dictionary(uniqueKeysWithValues: kegs.map { ($0.id, $0) })
        var ordered: [Keg] = savedOrder.compactMap { lookup[$0] }
        let remaining = kegs.filter { keg in !savedOrder.contains(keg.id) }
        ordered.append(contentsOf: remaining)
        return ordered
    }

    func moveKeg(from source: IndexSet, to destination: Int) {
        var ids = orderedKegs.map(\.id)
        ids.move(fromOffsets: source, toOffset: destination)
        UserDefaults.standard.set(ids, forKey: kegOrderKey)
        objectWillChange.send()
    }

    init() {
        loadTabOrder()

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
            } else {
                self.transferScales.append(updatedScale)
            }
        }
        ws.connect()
    }

    func moveTab(from source: IndexSet, to destination: Int) {
        tabOrder.move(fromOffsets: source, toOffset: destination)
        saveTabOrder()
    }

    func resetTabOrder() {
        tabOrder = AppTab.allCases
        saveTabOrder()
    }

    private func loadTabOrder() {
        let saved = UserDefaults.standard.stringArray(forKey: tabOrderKey) ?? []
        if saved.isEmpty {
            tabOrder = AppTab.allCases
            return
        }

        var ordered = saved.compactMap(AppTab.init(rawValue:))
        for tab in AppTab.allCases where !ordered.contains(tab) {
            ordered.append(tab)
        }
        tabOrder = ordered
    }

    private func saveTabOrder() {
        UserDefaults.standard.set(tabOrder.map(\.rawValue), forKey: tabOrderKey)
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
            await hydrateTransferScaleDetails()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshTransferScales() async {
        do {
            transferScales = try await api.fetchTransferScales()
            await hydrateTransferScaleDetails()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func hydrateTransferScaleDetails() async {
        var full: [TransferScale] = []
        for scale in transferScales {
            if let detailed = try? await api.fetchTransferScale(scale.id) {
                full.append(detailed)
            } else {
                full.append(scale)
            }
        }
        transferScales = full
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
