import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var isShowingCountryPicker = false
    @State private var isShowingTemplateManager = false
    @State private var noteEditorEntry: RecentEntry?
    @FocusState private var isPhoneFieldFocused: Bool
    @AppStorage("selectedCountryCode") private var selectedCountryCode = Country.fallback.code

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color.green.opacity(0.07),
                    Color(.systemBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    header
                    quickEntryCard

                    if let clipboardSuggestion = viewModel.clipboardSuggestion {
                        ClipboardSuggestionCard(number: clipboardSuggestion) {
                            viewModel.useClipboardSuggestion()
                            focusPhoneField()
                        }
                    }

                    TemplatePickerView(
                        templates: viewModel.templates,
                        selectedTemplateID: viewModel.selectedTemplateID,
                        onSelect: { template in
                            viewModel.selectTemplate(template)
                        },
                        onManage: {
                            isShowingTemplateManager = true
                        }
                    )

                    if let payload = viewModel.payloadPreview {
                        QuickActionBarView(
                            shareLink: payload.url.absoluteString,
                            onCopyLink: {
                                viewModel.copyGeneratedLink()
                            },
                            onCopyNumber: {
                                viewModel.copyCleanNumber()
                            }
                        )
                    }

                    FavoriteNumbersView(entries: viewModel.favoriteEntries) { entry in
                        viewModel.openRecent(entry)
                    }

                    RecentSectionView(
                        entries: viewModel.recentEntries,
                        onTap: { entry in
                            viewModel.openRecent(entry)
                        },
                        onToggleFavorite: { entry in
                            viewModel.toggleFavorite(for: entry)
                        },
                        onEditNote: { entry in
                            noteEditorEntry = entry
                        },
                        onDelete: { offsets in
                            viewModel.deleteRecentEntries(at: offsets)
                        }
                    )
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
                .frame(maxWidth: 640)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isPhoneFieldFocused = false
        }
        .sheet(isPresented: $isShowingCountryPicker) {
            CountryPickerView(
                countries: viewModel.countries,
                selectedCountry: $viewModel.selectedCountry
            )
        }
        .sheet(isPresented: $isShowingTemplateManager) {
            TemplateManagerView(
                templates: viewModel.templates,
                onAdd: { title, body in
                    viewModel.addTemplate(title: title, body: body)
                },
                onUpdate: { id, title, body in
                    viewModel.updateTemplate(id: id, title: title, body: body)
                },
                onDelete: { offsets in
                    viewModel.deleteTemplate(at: offsets)
                }
            )
        }
        .sheet(item: $noteEditorEntry) { entry in
            NoteEditorView(entry: entry) { updatedEntry, note in
                viewModel.updateNote(for: updatedEntry, note: note)
            }
        }
        .onAppear {
            viewModel.selectCountry(using: selectedCountryCode)
            viewModel.refreshClipboardSuggestion()
            focusPhoneField()
        }
        .onChange(of: viewModel.selectedCountry) { newCountry in
            selectedCountryCode = newCountry.code
        }
        .onOpenURL { url in
            guard url.scheme == "whatdirect" else { return }
            viewModel.refreshClipboardSuggestion()
            focusPhoneField()
        }
        .alert("Número inválido", isPresented: errorAlertBinding) {
            Button("OK", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "Revisa el número ingresado.")
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Ocultar") {
                    isPhoneFieldFocused = false
                }
            }
        }
    }

    private var header: some View {
        VStack(spacing: 10) {
            Image(systemName: "message.circle.fill")
                .font(.system(size: 58))
                .foregroundStyle(Color.green)

            Text("What Direct")
                .font(.system(size: 36, weight: .bold, design: .rounded))

            Text("WhatsApp directo, rápido y sin ruido.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("Directo a WhatsApp")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.green)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(
                    Capsule(style: .continuous)
                        .fill(Color.green.opacity(0.12))
                )
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 12)
    }

    private var quickEntryCard: some View {
        VStack(spacing: 18) {
            Button {
                isShowingCountryPicker = true
            } label: {
                HStack(spacing: 12) {
                    Text(viewModel.selectedCountry.flag)
                        .font(.title2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewModel.selectedCountry.name)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text("Código \(viewModel.selectedCountry.code)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(16)
                .background(inputCardBackground)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 10) {
                Text("Número telefónico")
                    .font(.headline)

                HStack(spacing: 12) {
                    Text(viewModel.selectedCountry.code)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)

                    Rectangle()
                        .fill(Color.primary.opacity(0.08))
                        .frame(width: 1, height: 28)

                    TextField("912345678", text: $viewModel.phoneNumber)
                        .keyboardType(.numberPad)
                        .textContentType(.telephoneNumber)
                        .focused($isPhoneFieldFocused)
                        .font(.system(size: 30, weight: .semibold, design: .rounded))
                        .onChange(of: viewModel.phoneNumber) { newValue in
                            viewModel.syncPhoneNumber(newValue)
                        }
                }
                .padding(18)
                .background(inputCardBackground)

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }

                if let selectedTemplate = viewModel.selectedTemplate {
                    HStack(spacing: 8) {
                        Image(systemName: "text.bubble")
                            .foregroundStyle(Color.green)
                        Text(selectedTemplate.title)
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                    }
                    .foregroundStyle(.secondary)
                }
            }

            Button {
                isPhoneFieldFocused = false
                viewModel.openWhatsApp()
            } label: {
                HStack {
                    Image(systemName: "paperplane.fill")
                    Text("Abrir en WhatsApp")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.12, green: 0.73, blue: 0.38),
                                    Color(red: 0.06, green: 0.58, blue: 0.29)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
            }
            .buttonStyle(.plain)
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color.primary.opacity(0.05), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 18, y: 10)
    }

    private var errorAlertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    viewModel.errorMessage = nil
                }
            }
        )
    }

    private var inputCardBackground: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(Color(.secondarySystemBackground))
    }

    private func focusPhoneField() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isPhoneFieldFocused = true
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
