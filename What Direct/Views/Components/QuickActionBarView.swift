import SwiftUI

struct QuickActionBarView: View {
    let shareLink: String
    let onCopyLink: () -> Void
    let onCopyNumber: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            actionButton(title: "Copiar link", systemImage: "link", action: onCopyLink)
            actionButton(title: "Copiar número", systemImage: "number.circle", action: onCopyNumber)

            ShareLink(item: shareLink) {
                Label("Compartir", systemImage: "square.and.arrow.up")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .foregroundStyle(.primary)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
        }
    }

    private func actionButton(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.primary)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
}
