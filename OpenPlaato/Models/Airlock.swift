import Foundation

struct Airlock: Identifiable, Codable {
    var deviceId: String
    var name: String?
    var gravity: Double?
    var temperature: Double?
    var battery: Int?

    var id: String { deviceId }

    enum CodingKeys: String, CodingKey {
        case deviceId = "device_id"
        case name, gravity, temperature, battery
    }

    var gravityFormatted: String {
        guard let g = gravity else { return "—" }
        return String(format: "%.3f SG", g)
    }
    var tempFormatted: String {
        guard let t = temperature else { return "—" }
        return String(format: "%.1f°F", t)
    }
}
