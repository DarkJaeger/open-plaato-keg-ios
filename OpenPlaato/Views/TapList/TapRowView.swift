import SwiftUI

struct TapRowView: View {
    let tap: Tap
    let keg: Keg?

    var body: some View {
        HStack(spacing: 12) {
            // Handle image or placeholder
            Group {
                if let url = tap.handleImageUrl, let imageURL = URL(string: url) {
                    AsyncImage(url: imageURL) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                } else {
                    Image(systemName: "drop.fill")
                        .font(.title2)
                        .foregroundColor(.accentColor)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.accentColor.opacity(0.1))
                }
            }
            .frame(width: 50, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(tap.name).font(.headline)
                if let style = tap.style, !style.isEmpty {
                    Text(style).font(.subheadline).foregroundColor(.secondary)
                } else {
                    Text("No keg assigned").font(.subheadline).foregroundColor(.secondary)
                }
            }

            Spacer()

            if let keg = keg {
                VStack(alignment: .trailing, spacing: 4) {
                    if keg.isPouringBool {
                        Label("Pouring", systemImage: "drop.fill")
                            .font(.caption).foregroundColor(.blue)
                    }
                    Text(keg.percentFormatted)
                        .font(.title3).bold()
                        .foregroundColor(Color.forPercent(keg.percentDouble))
                    Text(keg.tempFormatted)
                        .font(.caption).foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
