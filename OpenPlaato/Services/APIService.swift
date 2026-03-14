import Foundation

class APIService {
    static let shared = APIService()
    private var baseURL: String {
        UserDefaults.standard.string(forKey: "serverURL") ?? "http://192.168.8.141:8085"
    }

    private func url(_ path: String) -> URL {
        URL(string: "\(baseURL)\(path)")!
    }

    // MARK: - Taps
    func fetchTaps() async throws -> [Tap] {
        let (data, _) = try await URLSession.shared.data(from: url("/api/taps"))
        return try JSONDecoder().decode([Tap].self, from: data)
    }

    func updateTap(_ tap: Tap) async throws {
        var req = URLRequest(url: url("/api/taps/\(tap.id)"))
        req.httpMethod = "PUT"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(tap)
        _ = try await URLSession.shared.data(for: req)
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

    // MARK: - Beers
    func fetchBeers() async throws -> [Beer] {
        let (data, _) = try await URLSession.shared.data(from: url("/api/beverages"))
        return try JSONDecoder().decode([Beer].self, from: data)
    }

    // MARK: - Airlocks
    func fetchAirlocks() async throws -> [Airlock] {
        let (data, _) = try await URLSession.shared.data(from: url("/api/airlocks"))
        return try JSONDecoder().decode([Airlock].self, from: data)
    }

    // MARK: - Image Upload
    func uploadHandleImage(_ imageData: Data, tapId: String) async throws -> String {
        var req = URLRequest(url: url("/api/taps/\(tapId)/handle-image"))
        req.httpMethod = "POST"
        let boundary = UUID().uuidString
        req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"handle.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        req.httpBody = body

        let (data, _) = try await URLSession.shared.data(for: req)
        let json = try JSONDecoder().decode([String: String].self, from: data)
        return json["url"] ?? ""
    }
}
