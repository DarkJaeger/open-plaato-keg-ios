import Foundation

struct ValueBody: Codable {
    let value: String
}

struct StatusResponse: Codable {
    let status: String?
    let error: String?
    let id: String?
}

struct AppConfigResponse: Codable {
    let airlockEnabled: Bool

    enum CodingKeys: String, CodingKey {
        case airlockEnabled = "airlock_enabled"
    }
}

struct AirlockEnabledBody: Codable {
    let enabled: Bool
}

struct BrewfatherConfigResponse: Codable {
    let configured: Bool
}

struct BrewfatherCredsBody: Codable {
    let userId: String
    let apiKey: String

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case apiKey = "api_key"
    }
}

struct BrewfatherBatch: Identifiable, Codable {
    let id: String
    let name: String
    let style: String
    let abv: Double?
    let status: String
}

struct GrainfatherBody: Codable {
    let enabled: Bool
    let unit: String
    let specificGravity: String
    let url: String

    enum CodingKeys: String, CodingKey {
        case enabled, unit, url
        case specificGravity = "specific_gravity"
    }
}

struct BrewfatherBody: Codable {
    let enabled: Bool
    let unit: String
    let specificGravity: String
    let url: String
    let og: String?
    let batchVolume: String?

    enum CodingKeys: String, CodingKey {
        case enabled, unit, url, og
        case specificGravity = "specific_gravity"
        case batchVolume     = "batch_volume"
    }
}

struct TapSaveBody: Codable {
    var tapNumber: Int?
    var name: String = ""
    var brewery: String = ""
    var style: String = ""
    var abv: String = ""
    var ibu: String = ""
    var color: String = "#c9a849"
    var description: String = ""
    var tastingNotes: String = ""
    var kegId: String?
    var handleImage: String?
    var deviceId: String?

    enum CodingKeys: String, CodingKey {
        case name, brewery, style, abv, ibu, color, description
        case tapNumber    = "tap_number"
        case tastingNotes = "tasting_notes"
        case kegId        = "keg_id"
        case handleImage  = "handle_image"
        case deviceId     = "device_id"
    }
}

struct BeverageSaveBody: Codable {
    var name: String = ""
    var brewery: String = ""
    var style: String = ""
    var abv: String = ""
    var ibu: String = ""
    var color: String = "#c9a849"
    var description: String = ""
    var tastingNotes: String = ""
    var og: String = ""
    var fg: String = ""
    var srm: String = ""

    enum CodingKeys: String, CodingKey {
        case name, brewery, style, abv, ibu, color, description, og, fg, srm
        case tastingNotes = "tasting_notes"
    }
}

struct TapHandleInfo: Codable {
    let filename: String
}
