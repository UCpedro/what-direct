import Foundation

struct Country: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let code: String
    let flag: String
}

extension Country {
    static let defaults: [Country] = [
        Country(name: "Chile", code: "+56", flag: "🇨🇱"),
        Country(name: "Argentina", code: "+54", flag: "🇦🇷"),
        Country(name: "México", code: "+52", flag: "🇲🇽"),
        Country(name: "Estados Unidos", code: "+1", flag: "🇺🇸"),
        Country(name: "España", code: "+34", flag: "🇪🇸"),
        Country(name: "Colombia", code: "+57", flag: "🇨🇴"),
        Country(name: "Perú", code: "+51", flag: "🇵🇪"),
        Country(name: "Brasil", code: "+55", flag: "🇧🇷")
    ]

    static let fallback = Country.defaults[0]
}
