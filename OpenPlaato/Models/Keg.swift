import Foundation

struct Keg: Identifiable, Codable {
    let id: String
    var myLabel: String?
    var kegTemperature: String?
    var kegTemperatureString: String?
    var percentOfBeerLeft: String?
    var isPouring: String?
    var amountLeft: String?
    var myBeerStyle: String?
    var maxKegVolume: String?
    var lastPourString: String?

    enum CodingKeys: String, CodingKey {
        case id
        case myLabel              = "my_label"
        case kegTemperature       = "keg_temperature"
        case kegTemperatureString = "keg_temperature_string"
        case percentOfBeerLeft    = "percent_of_beer_left"
        case isPouring            = "is_pouring"
        case amountLeft           = "amount_left"
        case myBeerStyle          = "my_beer_style"
        case maxKegVolume         = "max_keg_volume"
        case lastPourString       = "last_pour_string"
    }

    var name: String { myLabel ?? id }
    var isPouringBool: Bool { isPouring == "1" }

    var tempFormatted: String {
        kegTemperatureString ?? (kegTemperature.map { "\($0)°F" } ?? "—")
    }

    var percentFormatted: String {
        guard let p = percentOfBeerLeft, let val = Double(p) else { return "—" }
        return String(format: "%.0f%%", val)
    }

    var percentDouble: Double {
        Double(percentOfBeerLeft ?? "0") ?? 0
    }
}
