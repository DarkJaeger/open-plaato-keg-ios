import Foundation

struct TransferScale: Identifiable, Codable {
    let id: String
    var label: String?
    var raw_weight: Double?
    var empty_keg_weight: Double?
    var target_weight: Double?
    var fill_percent: Double?
    var last_updated: Int64?

    var displayName: String {
        label ?? id.prefix(8).uppercased()
    }

    var fillPercentage: Double {
        fill_percent ?? 0
    }

    var isTransferComplete: Bool {
        fillPercentage >= 100
    }
}

struct TransferScaleConfigBody: Codable {
    let label: String?
    let empty_keg_weight: Double?
    let target_weight: Double?

    init(label: String? = nil, emptyKegWeight: Double? = nil, targetWeight: Double? = nil) {
        self.label = label
        self.empty_keg_weight = emptyKegWeight
        self.target_weight = targetWeight
    }
}
