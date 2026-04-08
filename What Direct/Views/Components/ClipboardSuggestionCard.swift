import SwiftUI

struct ClipboardSuggestionCard: View {
    let number: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "doc.on.clipboard")
                    .foregroundStyle(Color.green)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Usar número copiado")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(PhoneNumberFormatter.display(number))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "arrow.down.circle.fill")
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
        }
        .buttonStyle(.plain)
    }
}

struct ClipboardSuggestionCard_Previews: PreviewProvider {
    static var previews: some View {
        ClipboardSuggestionCard(number: "56912345678", action: {})
            .padding()
    }
}
