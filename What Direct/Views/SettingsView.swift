import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var viewModel: HomeViewModel
    @State private var isShowingCountryPicker = false
    @State private var isShowingResetAlert = false

    var body: some View {
        Form {
            Section("Preferencias") {
                Button {
                    isShowingCountryPicker = true
                } label: {
                    HStack {
                        Text("País por defecto")
                        Spacer()
                        Text("\(viewModel.selectedCountry.flag) \(viewModel.selectedCountry.name)")
                            .foregroundStyle(WDTheme.mutedText)
                    }
                }

                Picker("App por defecto", selection: binding(\.defaultApp)) {
                    Text("WhatsApp").tag(ConversationApp.whatsapp)
                    Text("WhatsApp Business").tag(ConversationApp.whatsappBusiness)
                    Text("SMS").tag(ConversationApp.sms)
                }
            }

            Section("Experiencia") {
                Toggle("Sugerencias desde portapapeles", isOn: binding(\.clipboardSuggestionsEnabled))
                Toggle("Modo rápido", isOn: binding(\.quickModeEnabled))
                Toggle("Modo empresa / productividad", isOn: binding(\.productivityModeEnabled))
                Toggle("Mostrar SMS", isOn: binding(\.showSMSShortcut))
                Toggle("Mostrar Telegram", isOn: binding(\.showTelegramShortcut))
            }

            Section("Datos locales") {
                Button("Borrar todo", role: .destructive) {
                    isShowingResetAlert = true
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(WDBackground())
        .navigationTitle("Ajustes")
        .toolbarBackground(.thinMaterial, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(isPresented: $isShowingCountryPicker) {
            CountryPickerView()
                .environmentObject(viewModel)
        }
        .alert("Borrar datos", isPresented: $isShowingResetAlert) {
            Button("Cancelar", role: .cancel) {}
            Button("Borrar", role: .destructive) {
                viewModel.wipeAllData()
            }
        } message: {
            Text("Se eliminarán historial, guardados, plantillas personalizadas y ajustes locales.")
        }
    }

    private func binding<T>(_ keyPath: WritableKeyPath<AppSettings, T>) -> Binding<T> {
        Binding(
            get: { viewModel.settings[keyPath: keyPath] },
            set: { newValue in
                viewModel.updateSettings { settings in
                    settings[keyPath: keyPath] = newValue
                }
            }
        )
    }
}
