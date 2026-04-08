import SwiftUI

struct RecentListView: View {
    let entries: [RecentEntry]
    let onTap: (RecentEntry) -> Void
    let onDelete: (IndexSet) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Recientes")
                    .font(.headline)
                Spacer()
                Text("\(entries.count)")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            if entries.isEmpty {
                Text("Aún no has abierto números recientes.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 4)
            } else {
                List {
                    ForEach(entries) { entry in
                        Button {
                            onTap(entry)
                        } label: {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("+\(entry.fullNumber)")
                                        .font(.body.weight(.semibold))
                                        .foregroundStyle(.primary)
                                    Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "arrow.up.right.circle.fill")
                                    .foregroundStyle(Color.green)
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                        .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                        .listRowBackground(Color.clear)
                    }
                    .onDelete(perform: onDelete)
                }
                .listStyle(.plain)
                .frame(minHeight: 100, maxHeight: 280)
                .scrollContentBackground(.hidden)
            }
        }
    }
}

struct RecentListView_Previews: PreviewProvider {
    static var previews: some View {
        RecentListView(
            entries: [
                RecentEntry(id: UUID(), fullNumber: "56912345678", date: .now),
                RecentEntry(id: UUID(), fullNumber: "14155552671", date: .now.addingTimeInterval(-3600))
            ],
            onTap: { _ in },
            onDelete: { _ in }
        )
        .padding()
    }
}
