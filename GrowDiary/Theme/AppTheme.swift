import SwiftUI
import UIKit

enum AppTheme {
    static let accent = Color("AccentColor")

    static let babyPrimary = adaptiveColor(
        light: (0.96, 0.55, 0.66),
        dark: (0.98, 0.68, 0.76)
    )
    static let babySoft = adaptiveColor(
        light: (0.99, 0.88, 0.91),
        dark: (0.30, 0.16, 0.20)
    )
    static let petPrimary = adaptiveColor(
        light: (0.45, 0.72, 0.96),
        dark: (0.58, 0.78, 0.98)
    )
    static let petSoft = adaptiveColor(
        light: (0.88, 0.94, 0.99),
        dark: (0.16, 0.22, 0.30)
    )

    static let babyTint = babySoft
    static let petTint = petSoft

    static let cardBackground = Color(.secondarySystemGroupedBackground)
    static let screenBackground = Color(.systemGroupedBackground)
    static let elevatedBackground = Color(.tertiarySystemGroupedBackground)

    static let cornerRadius: CGFloat = 16
    static let smallCornerRadius: CGFloat = 12

    static func tint(for type: ProfileType) -> Color {
        switch type {
        case .baby: babyPrimary
        case .pet: petPrimary
        }
    }

    static func softBackground(for type: ProfileType) -> Color {
        switch type {
        case .baby: babySoft
        case .pet: petSoft
        }
    }

    static func headerGradient(for type: ProfileType) -> LinearGradient {
        LinearGradient(
            colors: [
                softBackground(for: type),
                softBackground(for: type).opacity(0.72),
                screenBackground,
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var appGradient: LinearGradient {
        LinearGradient(
            colors: [
                babySoft.opacity(0.55),
                petSoft.opacity(0.42),
                screenBackground,
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func cardShadowOpacity(for colorScheme: ColorScheme) -> Double {
        colorScheme == .dark ? 0.32 : 0.06
    }

    static func profileHeaderShadowOpacity(for colorScheme: ColorScheme) -> Double {
        colorScheme == .dark ? 0.28 : 0.12
    }

    private static func adaptiveColor(
        light: (CGFloat, CGFloat, CGFloat),
        dark: (CGFloat, CGFloat, CGFloat)
    ) -> Color {
        Color(uiColor: UIColor { traitCollection in
            let rgb = traitCollection.userInterfaceStyle == .dark ? dark : light
            return UIColor(red: rgb.0, green: rgb.1, blue: rgb.2, alpha: 1)
        })
    }
}

struct ScreenBackground: View {
    var body: some View {
        AppTheme.appGradient
            .ignoresSafeArea()
    }
}

struct CardStyle: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                    .strokeBorder(Color.primary.opacity(colorScheme == .dark ? 0.08 : 0.04), lineWidth: 1)
            }
            .shadow(
                color: .black.opacity(AppTheme.cardShadowOpacity(for: colorScheme)),
                radius: colorScheme == .dark ? 10 : 8,
                y: 3
            )
    }
}

struct AdaptiveCardShadow: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content.shadow(
            color: .black.opacity(AppTheme.cardShadowOpacity(for: colorScheme)),
            radius: colorScheme == .dark ? 10 : 8,
            y: 3
        )
    }
}

struct ProfileTypeBadge: View {
    @Environment(\.colorScheme) private var colorScheme
    let type: ProfileType

    var body: some View {
        Text(type.displayName)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .foregroundStyle(AppTheme.tint(for: type))
            .background(AppTheme.softBackground(for: type).opacity(colorScheme == .dark ? 0.85 : 1))
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .strokeBorder(AppTheme.tint(for: type).opacity(colorScheme == .dark ? 0.35 : 0.15), lineWidth: 1)
            }
    }
}

extension View {
    func cardStyle(padding: CGFloat = 16) -> some View {
        modifier(CardStyle(padding: padding))
    }

    func adaptiveCardShadow() -> some View {
        modifier(AdaptiveCardShadow())
    }
}
