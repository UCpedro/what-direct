import Foundation

struct Country: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let code: String
    let flag: String
    let isoCode: String

    init(name: String, code: String, flag: String, isoCode: String) {
        self.id = isoCode
        self.name = name
        self.code = code
        self.flag = flag
        self.isoCode = isoCode
    }
}

extension Country {
    static let defaults: [Country] = [
        Country(name: "Chile", code: "+56", flag: "🇨🇱", isoCode: "CL"),
        Country(name: "Argentina", code: "+54", flag: "🇦🇷", isoCode: "AR"),
        Country(name: "Bolivia", code: "+591", flag: "🇧🇴", isoCode: "BO"),
        Country(name: "Brasil", code: "+55", flag: "🇧🇷", isoCode: "BR"),
        Country(name: "Colombia", code: "+57", flag: "🇨🇴", isoCode: "CO"),
        Country(name: "Costa Rica", code: "+506", flag: "🇨🇷", isoCode: "CR"),
        Country(name: "Ecuador", code: "+593", flag: "🇪🇨", isoCode: "EC"),
        Country(name: "El Salvador", code: "+503", flag: "🇸🇻", isoCode: "SV"),
        Country(name: "España", code: "+34", flag: "🇪🇸", isoCode: "ES"),
        Country(name: "Estados Unidos", code: "+1", flag: "🇺🇸", isoCode: "US"),
        Country(name: "Guatemala", code: "+502", flag: "🇬🇹", isoCode: "GT"),
        Country(name: "Honduras", code: "+504", flag: "🇭🇳", isoCode: "HN"),
        Country(name: "México", code: "+52", flag: "🇲🇽", isoCode: "MX"),
        Country(name: "Nicaragua", code: "+505", flag: "🇳🇮", isoCode: "NI"),
        Country(name: "Panamá", code: "+507", flag: "🇵🇦", isoCode: "PA"),
        Country(name: "Paraguay", code: "+595", flag: "🇵🇾", isoCode: "PY"),
        Country(name: "Perú", code: "+51", flag: "🇵🇪", isoCode: "PE"),
        Country(name: "Portugal", code: "+351", flag: "🇵🇹", isoCode: "PT"),
        Country(name: "República Dominicana", code: "+1", flag: "🇩🇴", isoCode: "DO"),
        Country(name: "Uruguay", code: "+598", flag: "🇺🇾", isoCode: "UY"),
        Country(name: "Venezuela", code: "+58", flag: "🇻🇪", isoCode: "VE")
    ]

    static let fallback = Country.defaults.first(where: { $0.isoCode == "CL" }) ?? Country.defaults[0]
}
