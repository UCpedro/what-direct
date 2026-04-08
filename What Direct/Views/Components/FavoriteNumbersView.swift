import SwiftUI

struct FavoriteNumbersView: View {
    let entries: [RecentEntry]
    let onTap: (RecentEntry) -> Void

    var body: some View {
        if !entries.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Favoritos")
                    .font(.headline)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(entries) { entry in
                            Button {
                                onTap(entry)
                            } label: {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "star.fill")
                                            .foregroundStyle(Color.yellow)
                                        Spacer()
                                        Image(systemName: "arrow.up.right")
                                            .foregroundStyle(.secondary)
                                    }

                                    Text(PhoneNumberFormatter.display(entry.fullNumber))
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.primary)

                                    Text(entry.note.isEmpty ? "Sin nota" : entry.note)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                }
                                .frame(width: 170, alignment: .leading)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .fill(Color(.secondarySystemBackground))
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }
}
