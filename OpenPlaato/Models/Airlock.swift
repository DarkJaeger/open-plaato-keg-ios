import Foundation

struct Airlock: Identifiable, Codable {
    let id: String
    var label: String?
    var temperature: String?
    var bubblesPerMin: String?
    var brewfatherSg: String?
    var brewfatherOg: String?

    enum CodingKeys: String, CodingKey {
        case id, label, temperature
        case bubblesPerMin = "bubbles_per_min"
        case brewfatherSg  = "brewfather_sg"
        case brewfatherOg  = "brewfather_og"
    }

    var name: String { label ?? id }

    var gravityFormatted: String {
        guard let sg = brewfatherSg, !sg.isEmpty, let val = Double(sg) else { return "—" }
        return String(format: "%.3f SG", val)
    }

    var tempFormatted: String {
        guard let t = temperature, !t.isEmpty, let val = Double(t) else { return "—" }
        // API returns celsius for airlocks
        let f = val * 9/5 + 32
        return String(format: "%.1f°F", f)
    }
}
