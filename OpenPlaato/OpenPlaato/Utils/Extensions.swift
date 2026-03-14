import SwiftUI

// MARK: - Brand Colors (matching Android amber palette)

extension Color {
    static let amber400 = Color(red: 0xFB/255, green: 0xBF/255, blue: 0x24/255)  // #FBBF24
    static let amber500 = Color(red: 0xF5/255, green: 0x9E/255, blue: 0x0B/255)  // #F59E0B
    static let amber600 = Color(red: 0xD9/255, green: 0x77/255, blue: 0x06/255)  // #D97706
    static let amberDark = Color(red: 0x92/255, green: 0x40/255, blue: 0x0E/255) // #92400E

    static let pouringGreen = Color(red: 0x22/255, green: 0xC5/255, blue: 0x5E/255) // #22C55E
    static let lowRed = Color(red: 0xEF/255, green: 0x44/255, blue: 0x44/255)       // #EF4444

    static let kegGreen  = pouringGreen
    static let kegOrange = amber500
    static let kegRed    = lowRed

    static func forPercent(_ pct: Double) -> Color {
        if pct > 50 { return .kegGreen }
        if pct > 20 { return .kegOrange }
        return .kegRed
    }

    init?(hex: String) {
        var str = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if str.hasPrefix("#") { str.removeFirst() }
        guard str.count == 6, let num = UInt64(str, radix: 16) else { return nil }
        let r = Double((num >> 16) & 0xFF) / 255
        let g = Double((num >> 8) & 0xFF) / 255
        let b = Double(num & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }

    func toHex() -> String {
        guard let c = UIColor(self).cgColor.components, c.count >= 3 else { return "#c9a849" }
        let r = Int(c[0] * 255)
        let g = Int(c[1] * 255)
        let b = Int(c[2] * 255)
        return String(format: "#%02x%02x%02x", r, g, b)
    }
}

// MARK: - Double

extension Double {
    func rounded(to places: Int) -> Double {
        let factor = pow(10.0, Double(places))
        return (self * factor).rounded() / factor
    }
}

// MARK: - View

extension View {
    func cardStyle() -> some View {
        self
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - UIImage

extension UIImage {
    func resizedTo(_ size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
