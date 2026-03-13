import SwiftUI

extension Double {
    func rounded(to places: Int) -> Double {
        let factor = pow(10.0, Double(places))
        return (self * factor).rounded() / factor
    }
}

extension Color {
    static let kegGreen  = Color.green
    static let kegOrange = Color.orange
    static let kegRed    = Color.red

    static func forPercent(_ pct: Double) -> Color {
        if pct > 50 { return .kegGreen }
        if pct > 20 { return .kegOrange }
        return .kegRed
    }
}

extension View {
    func cardStyle() -> some View {
        self
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
