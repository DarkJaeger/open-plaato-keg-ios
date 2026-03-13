import Foundation

struct Beer: Identifiable, Codable {
    let id: Int
    var name: String
    var style: String?
    var abv: Double?
    var ibu: Int?
    var imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case id, name, style, abv, ibu
        case imageUrl = "image_url"
    }
}
