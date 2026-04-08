import SwiftUI

struct RecentSectionView: View {
    let entries: [RecentEntry]
    let onTap: (RecentEntry) -> Void
    let onToggleFavorite: (RecentEntry) -> Void
    let onEditNote: (RecentEntry) -> Void
    let onDelete: (IndexSet) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader

            if entries.isEmpty {
                emptyState
            } else {
                contentList
            }
        }
    }

    private var sectionHeader: some View {
        HStack {
            Text("Recientes")
                .font(.headline)
            Spacer()
            Text("\(entries.count)")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
        }
    }

    private var emptyState: some View {
        Text("Tus conversaciones recientes aparecerán aquí.")
            .font(.footnote)
            .foregroundStyle(.secondary)
    }

    private var contentList: some View {
        LazyVStack(spacing: 12) {
            ForEach(entries) { entry in
                recentRow(for: entry)
            }
        }
    }

    @ViewBuilder
    private func recentRow(for entry: RecentEntry) -> some View {
        let deleteIndex = entries.firstIndex(where: { $0.id == entry.id }) ?? 0

        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(PhoneNumberFormatter.display(entry.fullNumber))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)

                    if entry.isFavorite {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundStyle(Color.yellow)
                    }
                }

                Text(noteText(for: entry))
                    .font(.caption)
                    .foregroundStyle(noteColor(for: entry))

                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(spacing: 10) {
                Button {
                    onToggleFavorite(entry)
                } label: {
                    Image(systemName: entry.isFavorite ? "star.fill" : "star")
                        .foregroundStyle(entry.isFavorite ? Color.yellow : .secondary)
                }
                .buttonStyle(.plain)

                Button {
                    onEditNote(entry)
                } label: {
                    Image(systemName: "square.and.pencil")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap(entry)
        }
        .padding(16)
        .background(rowBackground)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete(IndexSet(integer: deleteIndex))
            } label: {
                Label("Eliminar", systemImage: "trash")
            }
        }
    }

    private var rowBackground: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(Color(.secondarySystemBackground))
    }

    private func noteText(for entry: RecentEntry) -> String {
        entry.note.isEmpty ? "Sin nota" : entry.note
    }

    private func noteColor(for entry: RecentEntry) -> Color {
        entry.note.isEmpty ? .secondary.opacity(0.8) : .secondary
    }
}
