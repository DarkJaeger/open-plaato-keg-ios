import Foundation

struct Tap: Identifiable, Codable {
    let id: Int
    var name: String
    var kegId: Int?
    var handleImageUrl: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case kegId = "keg_id"
        case handleImageUrl = "handle_image_url"
    }
}
