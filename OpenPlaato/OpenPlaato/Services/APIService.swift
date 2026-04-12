import Foundation

class APIService {
    static let shared = APIService()
    private var baseURL: String {
        let stored = UserDefaults.standard.string(forKey: "serverURL") ?? ""
        return normalizeBaseURL(stored.isEmpty ? "http://192.168.8.141:8085" : stored)
    }

    private func url(_ path: String) throws -> URL {
        guard let url = URL(string: "\(baseURL)\(path)") else {
            throw URLError(.badURL)
        }
        return url
    }

    private func normalizeBaseURL(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard !trimmed.isEmpty else { return "" }
        if trimmed.hasPrefix("http://") || trimmed.hasPrefix("https://") {
            return trimmed
        }
        return "http://\(trimmed)"
    }

    private func normalizedVersion(_ version: String?) -> String? {
        guard let trimmed = version?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty else { return nil }
        return trimmed.hasPrefix("v") ? String(trimmed.dropFirst()) : trimmed
    }

    private func versionComponent(_ component: String?) -> Int {
        guard let component else { return 0 }
        if let value = Int(component) { return value }
        let digits = component.filter(\.isNumber)
        return Int(digits) ?? 0
    }

    private func isVersionOlder(_ currentVersion: String?, _ latestVersion: String?) -> Bool {
        guard let currentVersion, let latestVersion else { return false }
        let currentParts = currentVersion.split(whereSeparator: { $0 == "." || $0 == "-" || $0 == "_" }).map(String.init)
        let latestParts = latestVersion.split(whereSeparator: { $0 == "." || $0 == "-" || $0 == "_" }).map(String.init)
        let maxParts = max(currentParts.count, latestParts.count)

        for index in 0..<maxParts {
            let current = versionComponent(index < currentParts.count ? currentParts[index] : nil)
            let latest = versionComponent(index < latestParts.count ? latestParts[index] : nil)
            if current < latest { return true }
            if current > latest { return false }
        }

        return false
    }

    private func post<T: Encodable>(_ path: String, body: T) async throws {
        var req = URLRequest(url: try url(path))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(body)
        _ = try await URLSession.shared.data(for: req)
    }

    private func postEmpty(_ path: String) async throws {
        var req = URLRequest(url: try url(path))
        req.httpMethod = "POST"
        _ = try await URLSession.shared.data(for: req)
    }

    // MARK: - Taps
    func fetchTaps() async throws -> [Tap] {
        let (data, _) = try await URLSession.shared.data(from: url("/api/taps"))
        return try JSONDecoder().decode([Tap].self, from: data)
    }

    func saveTap(_ id: String, body: TapSaveBody) async throws {
        try await post("/api/taps/\(id)", body: body)
    }

    func deleteTap(_ id: String) async throws {
        try await postEmpty("/api/taps/\(id)/delete")
    }

    // MARK: - Tap Handles
    func fetchTapHandles() async throws -> [TapHandleInfo] {
        let (data, _) = try await URLSession.shared.data(from: url("/api/tap-handles"))
        return try JSONDecoder().decode([TapHandleInfo].self, from: data)
    }

    func uploadHandleImage(_ imageData: Data) async throws -> String {
        var req = URLRequest(url: try url("/api/tap-handles/upload"))
        req.httpMethod = "POST"
        let boundary = UUID().uuidString
        req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"handle.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        req.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: req)
        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            let msg = (try? JSONDecoder().decode([String: String].self, from: data))?["error"] ?? "Upload failed (\(http.statusCode))"
            throw NSError(domain: "APIService", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: msg])
        }
        let json = try JSONDecoder().decode([String: String].self, from: data)
        guard let filename = json["filename"], !filename.isEmpty else {
            throw NSError(domain: "APIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Server returned no filename"])
        }
        return filename
    }

    // MARK: - Kegs
    func fetchKegs() async throws -> [Keg] {
        let (data, _) = try await URLSession.shared.data(from: url("/api/kegs"))
        return try JSONDecoder().decode([Keg].self, from: data)
    }

    func fetchKeg(_ id: String) async throws -> Keg {
        let (data, _) = try await URLSession.shared.data(from: url("/api/kegs/\(id)"))
        return try JSONDecoder().decode(Keg.self, from: data)
    }

    // MARK: - Scale Commands
    func setUnit(_ kegId: String, value: String) async throws {
        try await post("/api/kegs/\(kegId)/unit", body: ValueBody(value: value))
    }

    func setMeasureUnit(_ kegId: String, value: String) async throws {
        try await post("/api/kegs/\(kegId)/measure-unit", body: ValueBody(value: value))
    }

    func setSensitivity(_ kegId: String, value: String) async throws {
        try await post("/api/kegs/\(kegId)/sensitivity", body: ValueBody(value: value))
    }

    func setKegMode(_ kegId: String, value: String) async throws {
        try await post("/api/kegs/\(kegId)/keg-mode", body: ValueBody(value: value))
    }

    func tare(_ kegId: String) async throws {
        try await postEmpty("/api/kegs/\(kegId)/tare")
    }

    func tareRelease(_ kegId: String) async throws {
        try await postEmpty("/api/kegs/\(kegId)/tare-release")
    }

    func emptyKeg(_ kegId: String) async throws {
        try await postEmpty("/api/kegs/\(kegId)/empty-keg")
    }

    func emptyKegRelease(_ kegId: String) async throws {
        try await postEmpty("/api/kegs/\(kegId)/empty-keg-release")
    }

    func setEmptyKegWeight(_ kegId: String, value: String) async throws {
        try await post("/api/kegs/\(kegId)/empty-keg-weight", body: ValueBody(value: value))
    }

    func setMaxKegVolume(_ kegId: String, value: String) async throws {
        try await post("/api/kegs/\(kegId)/max-keg-volume", body: ValueBody(value: value))
    }

    func calibrateKnownWeight(_ kegId: String, value: String) async throws {
        try await post("/api/kegs/\(kegId)/calibrate-known-weight", body: ValueBody(value: value))
    }

    func setTemperatureOffset(_ kegId: String, value: String) async throws {
        try await post("/api/kegs/\(kegId)/temperature-offset", body: ValueBody(value: value))
    }

    func resetLastPour(_ kegId: String) async throws {
        try await postEmpty("/api/kegs/\(kegId)/reset-last-pour")
    }

    func setLabel(_ kegId: String, value: String) async throws {
        try await post("/api/kegs/\(kegId)/label", body: ValueBody(value: value))
    }

    // MARK: - App Config
    func fetchAppConfig() async throws -> AppConfigResponse {
        let (data, _) = try await URLSession.shared.data(from: url("/api/config"))
        return try JSONDecoder().decode(AppConfigResponse.self, from: data)
    }

    func setAirlockEnabled(_ enabled: Bool) async throws {
        try await post("/api/config/airlock-enabled", body: AirlockEnabledBody(enabled: enabled))
    }

    func fetchBrewfatherConfig() async throws -> BrewfatherConfigResponse {
        let (data, _) = try await URLSession.shared.data(from: url("/api/config/brewfather"))
        return try JSONDecoder().decode(BrewfatherConfigResponse.self, from: data)
    }

    func saveBrewfatherCreds(userId: String, apiKey: String) async throws {
        try await post("/api/config/brewfather", body: BrewfatherCredsBody(userId: userId, apiKey: apiKey))
    }

    // MARK: - Brewfather Batch Import
    func fetchBrewfatherBatches() async throws -> [BrewfatherBatch] {
        let (data, _) = try await URLSession.shared.data(from: url("/api/brewfather/batches"))
        return try JSONDecoder().decode([BrewfatherBatch].self, from: data)
    }

    func importBrewfatherBatch(_ batchId: String) async throws {
        try await postEmpty("/api/brewfather/import/\(batchId)")
    }

    // MARK: - Beverages
    func fetchBeers() async throws -> [Beer] {
        let (data, _) = try await URLSession.shared.data(from: url("/api/beverages"))
        return try JSONDecoder().decode([Beer].self, from: data)
    }

    func saveBeverage(_ id: String, body: BeverageSaveBody) async throws {
        try await post("/api/beverages/\(id)", body: body)
    }

    func deleteBeverage(_ id: String) async throws {
        try await postEmpty("/api/beverages/\(id)/delete")
    }

    // MARK: - Airlocks
    func fetchAirlocks() async throws -> [Airlock] {
        let (data, _) = try await URLSession.shared.data(from: url("/api/airlocks"))
        return try JSONDecoder().decode([Airlock].self, from: data)
    }

    func setAirlockLabel(_ id: String, value: String) async throws {
        try await post("/api/airlocks/\(id)/label", body: ValueBody(value: value))
    }

    func setGrainfather(_ id: String, body: GrainfatherBody) async throws {
        try await post("/api/airlocks/\(id)/grainfather", body: body)
    }

    func setBrewfather(_ id: String, body: BrewfatherBody) async throws {
        try await post("/api/airlocks/\(id)/brewfather", body: body)
    }

    // MARK: - Transfer Scales
    func fetchTransferScales() async throws -> [TransferScale] {
        let (data, _) = try await URLSession.shared.data(from: url("/api/transfer-scales"))
        return try JSONDecoder().decode([TransferScale].self, from: data)
    }

    func fetchTransferScale(_ id: String) async throws -> TransferScale {
        let (data, _) = try await URLSession.shared.data(from: url("/api/transfer-scales/\(id)"))
        return try JSONDecoder().decode(TransferScale.self, from: data)
    }

    func configureTransferScale(_ id: String, body: TransferScaleConfigBody) async throws {
        try await post("/api/transfer-scales/\(id)/config", body: body)
    }

    func deleteTransferScale(_ id: String) async throws {
        try await postEmpty("/api/transfer-scales/\(id)/delete")
    }

    // MARK: - Server Version
    func fetchServerVersion() async throws -> String {
        let (data, _) = try await URLSession.shared.data(from: url("/api/alive"))
        let alive = try JSONDecoder().decode(AliveResponse.self, from: data)
        guard let version = normalizedVersion(alive.version) else {
            throw NSError(domain: "APIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Version field missing in /api/alive response"])
        }
        return version
    }

    func fetchLatestGithubVersion() async throws -> String {
        guard let url = URL(string: "https://api.github.com/repos/DarkJaeger/open-plaato-keg/releases/latest") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        let (data, _) = try await URLSession.shared.data(for: request)
        let release = try JSONDecoder().decode(GithubLatestReleaseResponse.self, from: data)
        guard let version = normalizedVersion(release.tagName) else {
            throw NSError(domain: "APIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Latest GitHub release tag missing"])
        }
        return version
    }

    func fetchServerVersionStatus() async throws -> ServerVersionStatus {
        let serverVersion = try await fetchServerVersion()
        let latestGithubVersion = try? await fetchLatestGithubVersion()
        return ServerVersionStatus(
            serverVersion: serverVersion,
            latestGithubVersion: latestGithubVersion,
            isUpdateAvailable: isVersionOlder(serverVersion, latestGithubVersion)
        )
    }
}
