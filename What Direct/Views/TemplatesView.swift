import SwiftUI

struct TemplatesView: View {
    @EnvironmentObject private var viewModel: HomeViewModel
    @State private var searchText = ""
    @State private var editingTemplate: MessageTemplate?
    @State private var isShowingCreate = false

    var body: some View {
        List {
            if !viewModel.favoriteTemplates.isEmpty {
                Section("Favoritas") {
                    ForEach(filteredFavoriteTemplates) { template in
                        templateRow(template)
                    }
                }
            }

            Section("Todas") {
                ForEach(filteredTemplates) { template in
                    templateRow(template)
                }
                .onDelete { offsets in
                    viewModel.deleteTemplates(at: offsets, filteredTemplates: filteredTemplates)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(WDBackground())
        .listStyle(.insetGrouped)
        .searchable(text: $searchText, prompt: "Buscar plantilla")
        .navigationTitle("Plantillas")
        .toolbarBackground(.thinMaterial, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowingCreate = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(item: $editingTemplate) { template in
            TemplateEditSheet(template: template) { updatedTemplate in
                viewModel.updateTemplate(updatedTemplate)
            }
        }
        .sheet(isPresented: $isShowingCreate) {
            TemplateCreateSheet { title, body in
                viewModel.addTemplate(title: title, body: body)
            }
        }
    }

    private var filteredTemplates: [MessageTemplate] {
        if searchText.isEmpty {
            return viewModel.templates
        }

        return viewModel.templates.filter { template in
            template.title.localizedCaseInsensitiveContains(searchText)
            || template.body.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var filteredFavoriteTemplates: [MessageTemplate] {
        if searchText.isEmpty {
            return viewModel.favoriteTemplates
        }

        return viewModel.favoriteTemplates.filter { template in
            template.title.localizedCaseInsensitiveContains(searchText)
            || template.body.localizedCaseInsensitiveContains(searchText)
        }
    }

    private func templateRow(_ template: MessageTemplate) -> some View {
        Button {
            viewModel.selectTemplate(template)
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(template.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Spacer()
                    if viewModel.selectedTemplateID == template.id {
                        WDBadge(title: "Activa", systemImage: "sparkles", tint: WDTheme.brand)
                    }
                }

                Text(template.body)
                    .font(.subheadline)
                    .foregroundStyle(WDTheme.mutedText)
                    .lineLimit(3)
            }
        }
        .buttonStyle(.plain)
        .wdListRowCard()
        .swipeActions(edge: .trailing) {
            Button {
                editingTemplate = template
            } label: {
                Label("Editar", systemImage: "square.and.pencil")
            }
            .tint(.orange)
        }
        .swipeActions(edge: .leading) {
            Button {
                viewModel.toggleFavorite(for: template)
            } label: {
                Label("Favorita", systemImage: template.isFavorite ? "star.slash" : "star")
            }
            .tint(.yellow)
        }
    }
}

private struct TemplateCreateSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var messageBody = ""
    let onSave: (String, String) -> Void

    var body: some View {
        NavigationStack {
            Form {
                TextField("Título", text: $title)
                TextField("Mensaje", text: $messageBody, axis: .vertical)
                    .lineLimit(5...10)
            }
            .scrollContentBackground(.hidden)
            .background(WDBackground())
            .navigationTitle("Nueva plantilla")
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
                        onSave(title, messageBody)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

private struct TemplateEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var draft: MessageTemplate
    let onSave: (MessageTemplate) -> Void

    init(template: MessageTemplate, onSave: @escaping (MessageTemplate) -> Void) {
        _draft = State(initialValue: template)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Título", text: $draft.title)
                TextField("Mensaje", text: $draft.body, axis: .vertical)
                    .lineLimit(5...10)
                Toggle("Favorita", isOn: $draft.isFavorite)
            }
            .scrollContentBackground(.hidden)
            .background(WDBackground())
            .navigationTitle("Editar plantilla")
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
                        onSave(draft)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
