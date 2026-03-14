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
    var lastPour: String?
    var beerLeftUnit: String?
    var temperatureUnit: String?
    var unit: String?
    var measureUnit: String?
    var sensitivity: String?
    var kegMode: String?
    var firmwareVersion: String?
    var wifiSignalStrength: String?
    var myOg: String?
    var myFg: String?
    var myAbv: String?
    var myKegDate: String?
    var emptyKegWeight: String?
    var weightRaw: String?
    var temperatureOffset: String?

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
        case lastPour             = "last_pour"
        case beerLeftUnit         = "beer_left_unit"
        case temperatureUnit      = "temperature_unit"
        case unit
        case measureUnit          = "measure_unit"
        case sensitivity
        case kegMode              = "keg_mode_c02_beer"
        case firmwareVersion      = "firmware_version"
        case wifiSignalStrength   = "wifi_signal_strength"
        case myOg                 = "my_og"
        case myFg                 = "my_fg"
        case myAbv                = "my_abv"
        case myKegDate            = "my_keg_date"
        case emptyKegWeight       = "empty_keg_weight"
        case weightRaw            = "weight_raw"
        case temperatureOffset    = "temperature_offset"
    }

    var name: String { myLabel ?? id }

    var isPouringBool: Bool {
        guard let v = isPouring, let num = Int(v) else { return false }
        return num != 0
    }

    var tempFormatted: String {
        kegTemperatureString ?? (kegTemperature.map { "\($0)°" } ?? "—")
    }

    var percentFormatted: String {
        guard let p = percentOfBeerLeft, let v = Double(p) else { return "—" }
        return String(format: "%.0f%%", v)
    }

    var percentDouble: Double {
        Double(percentOfBeerLeft ?? "0") ?? 0
    }

    var amountFormatted: String {
        guard let amount = amountLeft, let v = Double(amount) else { return "—" }
        let u = beerLeftUnit ?? "L"
        return String(format: "%.1f %@", v, u)
    }

    var lastPourDouble: Double? {
        guard let lp = lastPour else { return nil }
        return Double(lp)
    }

    var isLow: Bool {
        let pct = percentDouble
        return pct > 0.01 && pct < 20
    }
}
