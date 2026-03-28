import SwiftUI

// MARK: - Brand Colors (matching Android dark theme)

extension Color {
    // Amber brand
    static let amber400 = Color(red: 251.0/255, green: 191.0/255, blue: 36.0/255)   // #FBBF24
    static let amber500 = Color(red: 245.0/255, green: 158.0/255, blue: 11.0/255)   // #F59E0B
    static let amber600 = Color(red: 217.0/255, green: 119.0/255, blue: 6.0/255)    // #D97706
    static let amberDark = Color(red: 146.0/255, green: 64.0/255, blue: 14.0/255)   // #92400E

    // Dark surfaces (matching Android)
    static let darkBackground   = Color(red: 15.0/255, green: 15.0/255, blue: 15.0/255)   // #0F0F0F
    static let darkSurface      = Color(red: 26.0/255, green: 26.0/255, blue: 26.0/255)   // #1A1A1A
    static let darkSurfaceVar   = Color(red: 36.0/255, green: 36.0/255, blue: 36.0/255)   // #242424
    static let darkCard         = Color(red: 30.0/255, green: 30.0/255, blue: 30.0/255)   // #1E1E1E
    static let darkDivider      = Color(red: 42.0/255, green: 42.0/255, blue: 42.0/255)   // #2A2A2A
    static let onBackground     = Color(red: 245.0/255, green: 245.0/255, blue: 245.0/255) // #F5F5F5
    static let onSurface        = Color(red: 229.0/255, green: 229.0/255, blue: 229.0/255) // #E5E5E5
    static let onSurfaceMuted   = Color(red: 156.0/255, green: 163.0/255, blue: 175.0/255) // #9CA3AF

    // Status colors (pouringGreen and lowRed are defined in the asset catalog)

    static let kegGreen  = Color.pouringGreen
    static let kegOrange = amber500
    static let kegRed    = Color.lowRed

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
        let scale = max(size.width / self.size.width, size.height / self.size.height)
        let scaledSize = CGSize(width: self.size.width * scale, height: self.size.height * scale)
        let origin = CGPoint(
            x: (size.width - scaledSize.width) / 2,
            y: (size.height - scaledSize.height) / 2
        )
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: origin, size: scaledSize))
        }
    }
}
