import Foundation

@MainActor
class AppState: ObservableObject {
    @Published var taps: [Tap] = []
    @Published var kegs: [Keg] = []
    @Published var beers: [Beer] = []
    @Published var airlocks: [Airlock] = []
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
            (taps, kegs, beers, airlocks) = try await (t, k, b, a)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func keg(for tap: Tap) -> Keg? {
        guard let id = tap.kegId else { return nil }
        return kegs.first { $0.id == id }
    }
}
