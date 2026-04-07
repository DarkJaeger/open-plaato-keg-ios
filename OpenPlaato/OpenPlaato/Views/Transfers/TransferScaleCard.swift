import SwiftUI

struct TransferScaleCard: View {
    let scale: TransferScale

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(scale.displayName)
                        .font(.headline)
                    Text(scale.id.prefix(8).uppercased())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                if scale.isTransferComplete {
                    Label("Transfer complete", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                } else {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
            }

            VStack(spacing: 4) {
                Text(String(format: "%.2f kg", scale.raw_weight ?? 0))
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(red: 1.0, green: 0.647, blue: 0.0))
                Text("Current Weight")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            VStack(spacing: 4) {
                ProgressView(value: scale.fillPercentage / 100.0)
                    .tint(scale.isTransferComplete ? .green : Color(red: 1.0, green: 0.647, blue: 0.0))
                HStack {
                    Text("Fill Level")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(String(format: "%.1f%%", scale.fillPercentage))
                        .font(.caption)
                        .fontWeight(.semibold)
                }
            }

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Empty Weight")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.2f kg", scale.empty_keg_weight ?? 0))
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                Divider()
                VStack(alignment: .leading, spacing: 2) {
                    Text("Target Weight")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.2f kg", scale.target_weight ?? 0))
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                Spacer()
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}
