import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var viewModel: HomeViewModel
    @State private var recentToEdit: RecentEntry?
    @State private var isShowingClearAlert = false

    var body: some View {
        List {
            if viewModel.recentEntries.isEmpty {
                EmptyStateCard(
                    title: "Todavía no hay historial",
                    subtitle: "Las conversaciones abiertas aparecerán agrupadas por fecha.",
                    systemImage: "clock.badge.xmark"
                )
                .listRowBackground(Color.clear)
            } else {
                ForEach(viewModel.historySections) { section in
                    Section(section.title) {
                        ForEach(section.entries) { entry in
                            Button {
                                viewModel.openRecent(entry)
                            } label: {
                                historyRow(entry)
                            }
                            .buttonStyle(.plain)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    viewModel.deleteRecent(entry)
                                } label: {
                                    Label("Eliminar", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    viewModel.toggleFavorite(for: entry)
                                } label: {
                                    Label("Favorito", systemImage: entry.isFavorite ? "star.slash" : "star")
                                }
                                .tint(.yellow)

                                Button {
                                    recentToEdit = entry
                                } label: {
                                    Label("Nota", systemImage: "square.and.pencil")
                                }
                                .tint(.orange)
                            }
                        }
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(WDBackground())
        .listStyle(.insetGrouped)
        .navigationTitle("Historial")
        .toolbarBackground(.thinMaterial, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            if !viewModel.recentEntries.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Limpiar") {
                        isShowingClearAlert = true
                    }
                }
            }
        }
        .sheet(item: $recentToEdit) { entry in
            RecentNoteSheet(entry: entry) { note in
                viewModel.updateRecentNote(note, for: entry)
            }
        }
        .alert("Borrar historial", isPresented: $isShowingClearAlert) {
            Button("Cancelar", role: .cancel) {}
            Button("Borrar", role: .destructive) {
                viewModel.clearHistory()
            }
        } message: {
            Text("Se eliminarán todas las conversaciones recientes guardadas localmente.")
        }
    }

    private func historyRow(_ entry: RecentEntry) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(entry.alias.isEmpty ? PhoneNumberFormatter.display(entry.fullNumber) : entry.alias)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Spacer()
                WDBadge(title: entry.app.title, systemImage: "paperplane.fill", tint: WDTheme.accent)
            }

            Text(PhoneNumberFormatter.display(entry.fullNumber))
                .font(.subheadline)
                .foregroundStyle(WDTheme.mutedText)

            if !entry.note.isEmpty {
                Text(entry.note)
                    .font(.caption)
                    .foregroundStyle(WDTheme.mutedText)
            }

            Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                .font(.caption2)
                .foregroundStyle(WDTheme.mutedText)
        }
        .wdListRowCard()
        .padding(.vertical, 4)
    }
}

private struct RecentNoteSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var note: String

    let onSave: (String) -> Void

    init(entry: RecentEntry, onSave: @escaping (String) -> Void) {
        _note = State(initialValue: entry.note)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Nota", text: $note, axis: .vertical)
                    .lineLimit(4...8)
            }
            .scrollContentBackground(.hidden)
            .background(WDBackground())
            .navigationTitle("Editar nota")
            .toolbarBackground(.thinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Guardar") {
                        onSave(note)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
