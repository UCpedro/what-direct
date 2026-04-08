import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var viewModel: HomeViewModel
    @FocusState private var isInputFocused: Bool

    @State private var isShowingCountryPicker = false
    @State private var isShowingSaveContactSheet = false
    @State private var isShowingScanner = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: viewModel.settings.quickModeEnabled ? 16 : 22) {
                quickComposer
                clipboardCard
                templateStrip
                if !viewModel.favoriteContacts.isEmpty || !viewModel.favoriteHistoryEntries.isEmpty {
                    favoritesPreview
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            dismissKeyboard()
        }
        .background(WDBackground())
        .navigationTitle("Inicio")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.thinMaterial, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowingScanner = true
                } label: {
                    Image(systemName: "text.viewfinder")
                }
            }

            ToolbarItem(placement: .keyboard) {
                Button("Ocultar") {
                    dismissKeyboard()
                }
            }
        }
        .sheet(isPresented: $isShowingCountryPicker) {
            CountryPickerView()
                .environmentObject(viewModel)
        }
        .sheet(isPresented: $isShowingSaveContactSheet) {
            ContactSaveSheet(initialNumber: viewModel.payload.cleanNumber) { name, note, category, isFavorite in
                viewModel.saveCurrentNumberAsContact(name: name, note: note, category: category, isFavorite: isFavorite)
            }
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $isShowingScanner) {
            ScannerView { number in
                viewModel.useScannedNumber(number)
            }
        }
        .alert("Atención", isPresented: alertBinding) {
            Button("OK", role: .cancel) {
                viewModel.alertMessage = nil
            }
        } message: {
            Text(viewModel.alertMessage ?? "")
        }
        .task {
            viewModel.onLaunch()
            focusInput()
        }
        .onChange(of: viewModel.lastCopiedMessage) { _ in
            guard viewModel.lastCopiedMessage != nil else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                viewModel.clearCopiedFeedback()
            }
        }
    }

    private var quickComposer: some View {
        VStack(spacing: 18) {
            if let copiedMessage = viewModel.lastCopiedMessage {
                HStack {
                    Spacer()
                    WDBadge(title: copiedMessage, systemImage: "checkmark.circle.fill", tint: WDTheme.brand)
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                WDSectionTitle(
                    eyebrow: "Acción principal",
                    title: "Número directo",
                    subtitle: "Selecciona prefijo, escribe el número y abre la conversación."
                )

                HStack(spacing: 10) {
                    Button {
                        isShowingCountryPicker = true
                    } label: {
                        HStack(spacing: 3) {
                            Text(viewModel.selectedCountry.flag)
                                .font(.system(size: 18))
                            Text(viewModel.selectedCountry.code)
                                .font(.system(size: viewModel.settings.quickModeEnabled ? 20 : 18, weight: .bold, design: .rounded))
                                .lineLimit(1)
                                .minimumScaleFactor(0.9)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 9)
                        .background(WDTheme.brandSoft, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .fixedSize(horizontal: true, vertical: false)

                    Divider()
                        .frame(height: 24)

                    TextField("912345678", text: Binding(
                        get: { viewModel.phoneInput },
                        set: { viewModel.updatePhoneInput($0) }
                    ))
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
                    .focused($isInputFocused)
                    .font(.system(size: viewModel.settings.quickModeEnabled ? 26 : 22, weight: .semibold, design: .rounded))
                    .textInputAutocapitalization(.never)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(WDTheme.rowFill)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(WDTheme.stroke, lineWidth: 1)
                )

                WDBadge(title: statusTitle, systemImage: statusIcon, tint: statusColor)

                Text(viewModel.payload.validationMessage)
                    .font(.footnote)
                    .foregroundStyle(statusColor)
            }

            if let template = viewModel.selectedTemplate {
                HStack {
                    Label("Plantilla: \(template.title)", systemImage: "text.bubble.fill")
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Button("Quitar") {
                        viewModel.selectTemplate(nil)
                    }
                    .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(WDTheme.mutedText)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(WDTheme.brandSoft.opacity(0.7), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }

            VStack(spacing: 12) {
                primaryButton(title: "Abrir en \(viewModel.settings.defaultApp.title)", icon: viewModel.settings.defaultApp.systemImage) {
                    dismissKeyboard()
                    viewModel.openPreferredApp()
                }

                HStack(spacing: 12) {
                    if viewModel.canOpen(.whatsapp) {
                        secondaryButton(title: "WhatsApp", tint: WDTheme.brand) {
                            viewModel.open(using: .whatsapp)
                        }
                    }

                    if viewModel.canOpen(.whatsappBusiness) {
                        secondaryButton(title: "Business", tint: .teal) {
                            viewModel.open(using: .whatsappBusiness)
                        }
                    }
                }

                HStack(spacing: 12) {
                    if viewModel.settings.showSMSShortcut {
                        secondaryButton(title: "SMS", tint: .blue) {
                            viewModel.open(using: .sms)
                        }
                    }

                    if viewModel.settings.showTelegramShortcut, viewModel.canOpen(.telegram) {
                        secondaryButton(title: "Telegram", tint: .indigo) {
                            viewModel.open(using: .telegram)
                        }
                    }
                }
            }

            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    secondaryButton(title: "Guardar", tint: .orange) {
                        isShowingSaveContactSheet = true
                    }

                    secondaryButton(title: "Copiar número", tint: .gray) {
                        viewModel.copyCleanNumber()
                    }
                }

                HStack(spacing: 12) {
                    secondaryButton(title: "Copiar link", tint: .gray) {
                        viewModel.copyGeneratedLink()
                    }

                    if let shareURL = viewModel.payload.waURL {
                        ShareLink(item: shareURL) {
                            labelButton(title: "Compartir link", tint: .gray)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .wdCard(padding: 24)
    }

    @ViewBuilder
    private var clipboardCard: some View {
        if let clipboardSuggestion = viewModel.clipboardSuggestion {
            VStack(alignment: .leading, spacing: 12) {
                WDSectionTitle(
                    eyebrow: "Portapapeles",
                    title: "Número detectado",
                    subtitle: "Puedes traerlo al campo sin pegarlo manualmente."
                )
                Text(PhoneNumberFormatter.display(clipboardSuggestion))
                    .font(.title3.weight(.bold))
                Button("Usarlo ahora") {
                    viewModel.useClipboardSuggestion()
                    focusInput()
                }
                .buttonStyle(.borderedProminent)
                .tint(WDTheme.brand)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .wdCard()
        }
    }

    private var templateStrip: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                WDSectionTitle(
                    eyebrow: "Mensajes",
                    title: "Plantillas",
                    subtitle: "Usa un texto listo antes de abrir el chat."
                )
                Spacer()
                NavigationLink("Ver todas") {
                    TemplatesView()
                        .environmentObject(viewModel)
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(WDTheme.brand)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    templateChip(title: "Sin mensaje", selected: viewModel.selectedTemplate == nil) {
                        viewModel.selectTemplate(nil)
                    }

                    ForEach(viewModel.favoriteTemplates.isEmpty ? viewModel.templates : viewModel.favoriteTemplates) { template in
                        templateChip(title: template.title, selected: template.id == viewModel.selectedTemplateID) {
                            viewModel.selectTemplate(template)
                        }
                    }
                }
            }
            .padding(.top, 4)
        }
        .wdCard()
    }

    private var favoritesPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            WDSectionTitle(
                eyebrow: "Accesos rápidos",
                title: "Favoritos",
                subtitle: "Tus contactos y conversaciones más frecuentes."
            )

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.favoriteContacts.prefix(4)) { contact in
                        favoriteCard(title: contact.name, subtitle: contact.note.isEmpty ? PhoneNumberFormatter.display(contact.fullNumber) : contact.note) {
                            viewModel.openContact(contact)
                        }
                    }

                    ForEach(viewModel.favoriteHistoryEntries.prefix(4)) { entry in
                        favoriteCard(title: entry.alias.isEmpty ? PhoneNumberFormatter.display(entry.fullNumber) : entry.alias, subtitle: entry.app.title) {
                            viewModel.openRecent(entry)
                        }
                    }
                }
            }
            .padding(.top, 2)
        }
        .wdCard()
    }

    private func favoriteCard(title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .foregroundStyle(WDTheme.mutedText)
                }

                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(WDTheme.mutedText)
                    .lineLimit(2)
            }
            .frame(width: 180, alignment: .leading)
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(WDTheme.rowFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(WDTheme.stroke, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func primaryButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(
                LinearGradient(
                    colors: [WDTheme.brand, WDTheme.brand.opacity(0.82)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
        }
        .buttonStyle(.plain)
    }

    private func secondaryButton(title: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            labelButton(title: title, tint: tint)
        }
        .buttonStyle(.plain)
    }

    private func labelButton(title: String, tint: Color) -> some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(tint.opacity(0.10), lineWidth: 1)
            )
    }

    private func templateChip(title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(selected ? .white : .primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(selected ? WDTheme.brand : WDTheme.rowFill, in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private var statusTitle: String {
        switch viewModel.payload.validationState {
        case .valid:
            return "Válido"
        case .incomplete:
            return "Incompleto"
        case .invalid:
            return "Inválido"
        }
    }

    private var statusIcon: String {
        switch viewModel.payload.validationState {
        case .valid:
            return "checkmark.seal.fill"
        case .incomplete:
            return "hourglass"
        case .invalid:
            return "exclamationmark.triangle.fill"
        }
    }

    private var statusColor: Color {
        switch viewModel.payload.validationState {
        case .valid:
            return WDTheme.brand
        case .incomplete:
            return .orange
        case .invalid:
            return .red
        }
    }

    private var alertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.alertMessage != nil },
            set: { presented in
                if !presented {
                    viewModel.alertMessage = nil
                }
            }
        )
    }

    private func focusInput() {
        DispatchQueue.main.async {
            isInputFocused = true
        }
    }

    private func dismissKeyboard() {
        isInputFocused = false
    }
}

private struct ContactSaveSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var note = ""
    @State private var category: ContactCategory = .client
    @State private var isFavorite = true

    let initialNumber: String
    let onSave: (String, String, ContactCategory, Bool) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Número") {
                    Text(PhoneNumberFormatter.display(initialNumber))
                        .foregroundStyle(WDTheme.mutedText)
                }

                Section("Alias") {
                    TextField("Ej: Cliente Juan", text: $name)
                }

                Section("Detalle") {
                    Picker("Categoría", selection: $category) {
                        ForEach(ContactCategory.allCases) { category in
                            Text(category.title).tag(category)
                        }
                    }

                    TextField("Nota corta", text: $note, axis: .vertical)
                    Toggle("Marcar como favorito", isOn: $isFavorite)
                }
            }
            .scrollContentBackground(.hidden)
            .background(WDBackground())
            .navigationTitle("Guardar temporal")
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
                        onSave(name, note, category, isFavorite)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HomeView()
                .environmentObject(HomeViewModel())
        }
    }
}
