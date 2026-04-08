import SwiftUI

struct SavedContactsView: View {
    @EnvironmentObject private var viewModel: HomeViewModel
    @State private var searchText = ""
    @State private var editingContact: SavedContact?

    var body: some View {
        List {
            if !viewModel.favoriteContacts.isEmpty || !viewModel.favoriteHistoryEntries.isEmpty {
                Section("Favoritos") {
                    ForEach(viewModel.favoriteContacts) { contact in
                        contactRow(contact)
                    }

                    ForEach(viewModel.favoriteHistoryEntries) { entry in
                        favoriteHistoryRow(entry)
                    }
                }
            }

            Section("Contactos temporales") {
                if filteredContacts.isEmpty {
                    EmptyStateCard(
                        title: "Sin guardados todavía",
                        subtitle: "Guarda números con alias, categoría y nota sin tocar la agenda del iPhone.",
                        systemImage: "tray"
                    )
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(filteredContacts) { contact in
                        contactRow(contact)
                    }
                    .onDelete { offsets in
                        viewModel.deleteContacts(at: offsets, filteredContacts: filteredContacts)
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(WDBackground())
        .listStyle(.insetGrouped)
        .searchable(text: $searchText, prompt: "Buscar alias, número o nota")
        .navigationTitle("Guardados")
        .toolbarBackground(.thinMaterial, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(item: $editingContact) { contact in
            ContactEditSheet(contact: contact) { updatedContact in
                viewModel.updateContact(updatedContact)
            }
        }
    }

    private var filteredContacts: [SavedContact] {
        if searchText.isEmpty {
            return viewModel.savedContacts
        }

        return viewModel.savedContacts.filter { contact in
            contact.name.localizedCaseInsensitiveContains(searchText)
            || contact.note.localizedCaseInsensitiveContains(searchText)
            || contact.fullNumber.contains(PhoneNumberFormatter.clean(searchText))
        }
    }

    private func contactRow(_ contact: SavedContact) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                viewModel.openContact(contact)
            } label: {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(contact.name)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Spacer()
                        WDBadge(title: contact.category.title, systemImage: "tag.fill", tint: WDTheme.accent)
                    }

                    Text(PhoneNumberFormatter.display(contact.fullNumber))
                        .font(.subheadline)
                        .foregroundStyle(WDTheme.mutedText)

                    if !contact.note.isEmpty {
                        Text(contact.note)
                            .font(.caption)
                            .foregroundStyle(WDTheme.mutedText)
                    }
                }
            }
            .buttonStyle(.plain)

            HStack {
                actionChip("WhatsApp", tint: WDTheme.brand) {
                    viewModel.openContact(contact, app: .whatsapp)
                }

                if viewModel.canOpen(.whatsappBusiness) {
                    actionChip("Business", tint: .teal) {
                        viewModel.openContact(contact, app: .whatsappBusiness)
                    }
                }

                actionChip("Copiar", tint: .gray) {
                    viewModel.updatePhoneInput(contact.fullNumber)
                    viewModel.copyCleanNumber()
                }

                Button {
                    editingContact = contact
                } label: {
                    Image(systemName: "square.and.pencil")
                }
                .buttonStyle(.plain)

                Button {
                    viewModel.toggleFavorite(for: contact)
                } label: {
                    Image(systemName: contact.isFavorite ? "star.fill" : "star")
                        .foregroundStyle(.yellow)
                }
                .buttonStyle(.plain)
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(WDTheme.mutedText)
        }
        .wdListRowCard()
        .padding(.vertical, 6)
    }

    private func favoriteHistoryRow(_ entry: RecentEntry) -> some View {
        Button {
            viewModel.openRecent(entry)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.alias.isEmpty ? PhoneNumberFormatter.display(entry.fullNumber) : entry.alias)
                        .foregroundStyle(.primary)
                    Text(entry.app.title)
                        .font(.caption)
                        .foregroundStyle(WDTheme.mutedText)
                }
                Spacer()
                Image(systemName: "clock")
                    .foregroundStyle(WDTheme.mutedText)
            }
        }
        .buttonStyle(.plain)
        .wdListRowCard()
    }

    private func actionChip(_ title: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(title, action: action)
            .font(.caption.weight(.semibold))
            .foregroundStyle(tint)
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(tint.opacity(0.12), in: Capsule())
    }
}

private struct ContactEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var draft: SavedContact
    let onSave: (SavedContact) -> Void

    init(contact: SavedContact, onSave: @escaping (SavedContact) -> Void) {
        _draft = State(initialValue: contact)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Alias") {
                    TextField("Nombre", text: $draft.name)
                    Text(PhoneNumberFormatter.display(draft.fullNumber))
                        .foregroundStyle(WDTheme.mutedText)
                }

                Section("Organización") {
                    Picker("Categoría", selection: $draft.category) {
                        ForEach(ContactCategory.allCases) { category in
                            Text(category.title).tag(category)
                        }
                    }
                    Toggle("Favorito", isOn: $draft.isFavorite)
                }

                Section("Nota") {
                    TextField("Detalle", text: $draft.note, axis: .vertical)
                        .lineLimit(4...8)
                }
            }
            .scrollContentBackground(.hidden)
            .background(WDBackground())
            .navigationTitle("Editar guardado")
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
