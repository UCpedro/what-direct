import SwiftUI

enum WDTheme {
    static let brand = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
        ? UIColor(red: 0.29, green: 0.84, blue: 0.60, alpha: 1)
        : UIColor(red: 0.07, green: 0.62, blue: 0.39, alpha: 1)
    })

    static let brandSoft = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
        ? UIColor(red: 0.12, green: 0.19, blue: 0.16, alpha: 1)
        : UIColor(red: 0.90, green: 0.97, blue: 0.93, alpha: 1)
    })

    static let accent = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
        ? UIColor(red: 0.39, green: 0.67, blue: 0.95, alpha: 1)
        : UIColor(red: 0.16, green: 0.46, blue: 0.86, alpha: 1)
    })

    static let canvasTop = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
        ? UIColor(red: 0.05, green: 0.08, blue: 0.07, alpha: 1)
        : UIColor(red: 0.97, green: 0.98, blue: 0.99, alpha: 1)
    })

    static let canvasBottom = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
        ? UIColor(red: 0.03, green: 0.05, blue: 0.05, alpha: 1)
        : UIColor(red: 0.94, green: 0.96, blue: 0.97, alpha: 1)
    })

    static let cardFill = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
        ? UIColor(red: 0.10, green: 0.12, blue: 0.12, alpha: 0.92)
        : UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.88)
    })

    static let rowFill = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
        ? UIColor(red: 0.12, green: 0.14, blue: 0.14, alpha: 1)
        : UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.96)
    })

    static let stroke = Color.primary.opacity(0.08)
    static let mutedText = Color.secondary
    static let destructive = Color.red.opacity(0.9)
}

struct WDBackground: View {
    var body: some View {
        LinearGradient(
            colors: [WDTheme.canvasTop, WDTheme.canvasBottom],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(WDTheme.brand.opacity(0.10))
                .frame(width: 280, height: 280)
                .blur(radius: 30)
                .offset(x: 110, y: -70)
        }
        .overlay(alignment: .topLeading) {
            Circle()
                .fill(WDTheme.accent.opacity(0.08))
                .frame(width: 200, height: 200)
                .blur(radius: 25)
                .offset(x: -80, y: -60)
        }
        .ignoresSafeArea()
    }
}

struct WDCardModifier: ViewModifier {
    var padding: CGFloat = 18

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(WDTheme.cardFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(WDTheme.stroke, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.06), radius: 18, x: 0, y: 10)
    }
}

struct WDListRowCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(WDTheme.rowFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(WDTheme.stroke, lineWidth: 1)
            )
    }
}

struct WDBadge: View {
    let title: String
    let systemImage: String
    let tint: Color

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(tint.opacity(0.14), in: Capsule())
            .foregroundStyle(tint)
    }
}

struct WDSectionTitle: View {
    let eyebrow: String?
    let title: String
    let subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let eyebrow {
                Text(eyebrow.uppercased())
                    .font(.caption2.weight(.bold))
                    .tracking(1.2)
                    .foregroundStyle(WDTheme.brand)
            }
            Text(title)
                .font(.title3.weight(.bold))
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(WDTheme.mutedText)
            }
        }
    }
}

extension View {
    func wdCard(padding: CGFloat = 18) -> some View {
        modifier(WDCardModifier(padding: padding))
    }

    func wdListRowCard() -> some View {
        modifier(WDListRowCardModifier())
    }
}
