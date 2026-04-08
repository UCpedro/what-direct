import SwiftUI

struct NoteEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var note: String

    let entry: RecentEntry
    let onSave: (RecentEntry, String) -> Void

    init(entry: RecentEntry, onSave: @escaping (RecentEntry, String) -> Void) {
        self.entry = entry
        self.onSave = onSave
        _note = State(initialValue: entry.note)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Número") {
                    Text(PhoneNumberFormatter.display(entry.fullNumber))
                }

                Section("Nota rápida") {
                    TextField("Ej: cliente, gasfiter, Marketplace", text: $note, axis: .vertical)
                        .lineLimit(3...5)
                }
            }
            .navigationTitle("Editar nota")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Guardar") {
                        onSave(entry, note)
                        dismiss()
                    }
                }
            }
        }
    }
}
