import Foundation

struct Beer: Identifiable, Codable {
    let id: String
    var name: String
    var style: String?
    var abv: String?
    var ibu: String?
    var srm: String?
    var og: String?
    var fg: String?
    var brewery: String?
    var color: String?
    var description: String?
    var tastingNotes: String?
    var source: String?

    enum CodingKeys: String, CodingKey {
        case id, name, style, abv, ibu, srm, og, fg, brewery, color, description, source
        case tastingNotes = "tasting_notes"
    }

    var abvFormatted: String {
        guard let a = abv, !a.isEmpty, let val = Double(a) else { return "" }
        return String(format: "%.1f%% ABV", val)
    }

    var ibuFormatted: String {
        guard let i = ibu, !i.isEmpty, let val = Double(i) else { return "" }
        return String(format: "%.0f IBU", val)
    }
}
