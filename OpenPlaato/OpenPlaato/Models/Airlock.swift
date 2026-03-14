import Foundation

struct Airlock: Identifiable, Codable {
    let id: String
    var label: String?
    var temperature: String?
    var bubblesPerMin: String?
    var grainfatherEnabled: String?
    var grainfatherUnit: String?
    var grainfatherSpecificGravity: String?
    var grainfatherUrl: String?
    var brewfatherEnabled: String?
    var brewfatherTempUnit: String?
    var brewfatherSg: String?
    var brewfatherUrl: String?
    var brewfatherOg: String?
    var brewfatherBatchVolume: String?

    enum CodingKeys: String, CodingKey {
        case id, label, temperature
        case bubblesPerMin              = "bubbles_per_min"
        case grainfatherEnabled         = "grainfather_enabled"
        case grainfatherUnit            = "grainfather_unit"
        case grainfatherSpecificGravity = "grainfather_specific_gravity"
        case grainfatherUrl             = "grainfather_url"
        case brewfatherEnabled          = "brewfather_enabled"
        case brewfatherTempUnit         = "brewfather_temp_unit"
        case brewfatherSg               = "brewfather_sg"
        case brewfatherUrl              = "brewfather_url"
        case brewfatherOg               = "brewfather_og"
        case brewfatherBatchVolume      = "brewfather_batch_volume"
    }

    var displayName: String { label?.isEmpty == false ? label! : id }
    var isGrainfatherEnabled: Bool { grainfatherEnabled == "true" }
    var isBrewfatherEnabled: Bool { brewfatherEnabled == "true" }

    var gravityFormatted: String {
        guard let sg = brewfatherSg, !sg.isEmpty, let v = Double(sg) else { return "—" }
        return String(format: "%.3f SG", v)
    }

    var tempFormatted: String {
        guard let t = temperature, !t.isEmpty, let v = Double(t) else { return "—" }
        return String(format: "%.1f°C", v)
    }

    var bubblesFormatted: String {
        guard let b = bubblesPerMin, !b.isEmpty, let v = Double(b) else { return "—" }
        return String(format: "%.1f bpm", v)
    }
}
