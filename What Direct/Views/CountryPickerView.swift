import SwiftUI

struct CountryPickerView: View {
    let countries: [Country]
    @Binding var selectedCountry: Country
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(countries) { country in
                Button {
                    selectedCountry = country
                    dismiss()
                } label: {
                    HStack(spacing: 12) {
                        Text(country.flag)
                            .font(.title3)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(country.name)
                                .foregroundStyle(.primary)
                            Text(country.code)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if country == selectedCountry {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .navigationTitle("Selecciona un país")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            })
        }
    }
}

struct CountryPickerView_Previews: PreviewProvider {
    static var previews: some View {
        CountryPickerView(
            countries: Country.defaults,
            selectedCountry: .constant(.fallback)
        )
    }
}
