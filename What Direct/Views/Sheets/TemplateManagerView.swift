import SwiftUI

struct TemplateManagerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var editingTemplate: MessageTemplate?
    @State private var isPresentingEditor = false

    let templates: [MessageTemplate]
    let onAdd: (String, String) -> Void
    let onUpdate: (UUID, String, String) -> Void
    let onDelete: (IndexSet) -> Void

    var body: some View {
        NavigationStack {
            List {
                ForEach(templates) { template in
                    Button {
                        editingTemplate = template
                        isPresentingEditor = true
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(template.title)
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text(template.body)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }
                .onDelete(perform: onDelete)
            }
            .navigationTitle("Plantillas")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        editingTemplate = nil
                        isPresentingEditor = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isPresentingEditor) {
                TemplateEditorView(template: editingTemplate) { title, body in
                    if let editingTemplate {
                        onUpdate(editingTemplate.id, title, body)
                    } else {
                        onAdd(title, body)
                    }
                }
            }
        }
    }
}

private struct TemplateEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title: String
    @State private var bodyText: String

    let onSave: (String, String) -> Void

    init(template: MessageTemplate?, onSave: @escaping (String, String) -> Void) {
        _title = State(initialValue: template?.title ?? "")
        _bodyText = State(initialValue: template?.body ?? "")
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Título") {
                    TextField("Ej: Marketplace", text: $title)
                }

                Section("Mensaje") {
                    TextEditor(text: $bodyText)
                        .frame(minHeight: 160)
                }
            }
            .navigationTitle("Editar plantilla")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Guardar") {
                        onSave(title, bodyText)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || bodyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
