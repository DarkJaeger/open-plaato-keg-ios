import Foundation

struct Tap: Identifiable, Codable {
    let id: String
    var name: String
    var tapNumber: Int?
    var deviceId: String?
    var kegId: String?
    var handleImage: String?
    var style: String?
    var abv: String?
    var ibu: String?
    var brewery: String?
    var color: String?
    var description: String?
    var tastingNotes: String?

    enum CodingKeys: String, CodingKey {
        case id, name, style, abv, ibu, brewery, color, description
        case tapNumber    = "tap_number"
        case deviceId     = "device_id"
        case kegId        = "keg_id"
        case handleImage  = "handle_image"
        case tastingNotes = "tasting_notes"
    }

    var handleImageUrl: String? {
        guard let img = handleImage else { return nil }
        let base = UserDefaults.standard.string(forKey: "serverURL") ?? "http://192.168.8.141:8085"
        return "\(base)/static/images/\(img)"
    }
}
