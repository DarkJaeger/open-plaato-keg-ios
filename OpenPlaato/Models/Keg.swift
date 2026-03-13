import Foundation

struct Keg: Identifiable, Codable {
    let id: Int
    var name: String
    var beerId: Int?
    var percentOfBeerLeft: Double?
    var kegTemperature: Double?
    var isPouring: String?
    var litersRemaining: Double?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case beerId = "beer_id"
        case percentOfBeerLeft = "percent_of_beer_left"
        case kegTemperature = "keg_temperature"
        case isPouring = "is_pouring"
        case litersRemaining = "liters_remaining"
    }

    var isPouringBool: Bool { isPouring == "1" }
    var tempFormatted: String {
        guard let t = kegTemperature else { return "—" }
        return String(format: "%.1f°F", t)
    }
    var percentFormatted: String {
        guard let p = percentOfBeerLeft else { return "—" }
        return String(format: "%.0f%%", p)
    }
}
