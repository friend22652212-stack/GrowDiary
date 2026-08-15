import SwiftUI

enum AppTheme {
    static let accent = Color("AccentColor")
    static let babyTint = Color(red: 0.98, green: 0.72, blue: 0.76)
    static let petTint = Color(red: 0.72, green: 0.86, blue: 0.98)

    static func tint(for type: ProfileType) -> Color {
        switch type {
        case .baby: babyTint
        case .pet: petTint
        }
    }
}
