import SwiftUI

struct CountryPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: HomeViewModel
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            List {
                if !viewModel.preferredCountries.isEmpty {
                    Section("Frecuentes") {
                        ForEach(filteredPreferredCountries) { country in
                            countryRow(country)
                        }
                    }
                }

                Section("Todos") {
                    ForEach(filteredCountries) { country in
                        countryRow(country)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(WDBackground())
            .listStyle(.insetGrouped)
            .searchable(text: $searchText, prompt: "Buscar país o código")
            .navigationTitle("Selecciona país")
            .toolbarBackground(.thinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var filteredCountries: [Country] {
        if searchText.isEmpty {
            return viewModel.countries
        }

        return viewModel.countries.filter { country in
            country.name.localizedCaseInsensitiveContains(searchText)
            || country.code.contains(searchText)
            || country.isoCode.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var filteredPreferredCountries: [Country] {
        if searchText.isEmpty {
            return viewModel.preferredCountries
        }

        return viewModel.preferredCountries.filter { country in
            country.name.localizedCaseInsensitiveContains(searchText)
            || country.code.contains(searchText)
            || country.isoCode.localizedCaseInsensitiveContains(searchText)
        }
    }

    private func countryRow(_ country: Country) -> some View {
        Button {
            viewModel.selectCountry(country)
            dismiss()
        } label: {
            HStack(spacing: 14) {
                Text(country.flag)
                    .font(.title2)

                VStack(alignment: .leading, spacing: 3) {
                    Text(country.name)
                        .foregroundStyle(.primary)
                    Text("\(country.code) · \(country.isoCode)")
                        .font(.caption)
                        .foregroundStyle(WDTheme.mutedText)
                }

                Spacer()

                Button {
                    viewModel.toggleCountryFavorite(country)
                } label: {
                    Image(systemName: viewModel.settings.favoriteCountryCodes.contains(country.isoCode) ? "star.fill" : "star")
                        .foregroundStyle(.yellow)
                }
                .buttonStyle(.plain)
            }
        }
        .buttonStyle(.plain)
        .wdListRowCard()
    }
}
