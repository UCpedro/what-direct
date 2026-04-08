import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var isShowingCountryPicker = false
    @FocusState private var isPhoneFieldFocused: Bool
    @AppStorage("selectedCountryCode") private var selectedCountryCode = Country.fallback.code

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color.green.opacity(0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    VStack(spacing: 10) {
                        Image(systemName: "message.circle.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(Color.green)

                        Text("What Direct")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                    }

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
                            .padding()
                            .background(cardFill)
                        }
                        .buttonStyle(.plain)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Número telefónico")
                                .font(.headline)

                            TextField("912345678", text: $viewModel.phoneNumber)
                                .keyboardType(.numberPad)
                                .textContentType(.telephoneNumber)
                                .focused($isPhoneFieldFocused)
                                .font(.system(size: 28, weight: .semibold, design: .rounded))
                                .padding()
                                .background(cardFill)
                                .onChange(of: viewModel.phoneNumber) { newValue in
                                    viewModel.syncPhoneNumber(newValue)
                                }
                        }

                        if viewModel.canPasteNumber {
                            Button {
                                viewModel.pasteNumberFromClipboard()
                            } label: {
                                HStack {
                                    Image(systemName: "doc.on.clipboard")
                                    Text("Pegar número")
                                        .fontWeight(.semibold)
                                    Spacer()
                                }
                                .foregroundStyle(.primary)
                                .padding()
                                .background(cardFill)
                            }
                            .buttonStyle(.plain)
                        }

                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.footnote)
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        Button {
                            viewModel.openWhatsApp()
                        } label: {
                            Text("Abrir en WhatsApp")
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

                        RecentListView(
                            entries: viewModel.recentEntries,
                            onTap: { entry in
                                viewModel.openRecent(entry)
                            },
                            onDelete: { offsets in
                                viewModel.deleteRecentEntries(at: offsets)
                            }
                        )
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(Color(.systemBackground).opacity(0.92))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(Color.primary.opacity(0.05), lineWidth: 1)
                    )
                }
                .padding(24)
                .frame(maxWidth: 560)
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
        .onAppear {
            viewModel.selectCountry(using: selectedCountryCode)
            viewModel.refreshClipboardSuggestion()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                isPhoneFieldFocused = true
            }
        }
        .onChange(of: viewModel.selectedCountry) { newCountry in
            selectedCountryCode = newCountry.code
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

    private var cardFill: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(Color(.secondarySystemBackground))
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
