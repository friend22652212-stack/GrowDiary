import Foundation

struct WidgetProfileSnapshot: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let typeRawValue: String
    let birthDate: Date
    let ageDescription: String
    let latestEntryTitle: String?
    let latestEntryDate: Date?
    let hasThumbnail: Bool
    let updatedAt: Date

    var typeDisplayName: String {
        switch typeRawValue {
        case ProfileType.pet.rawValue: L10n.string("profile.type.pet")
        default: L10n.string("profile.type.baby")
        }
    }

    var systemImage: String {
        switch typeRawValue {
        case ProfileType.pet.rawValue: "pawprint.fill"
        default: "figure.and.child.holdinghands"
        }
    }

    var accentRed: Double {
        typeRawValue == ProfileType.pet.rawValue ? 0.45 : 0.96
    }

    var accentGreen: Double {
        typeRawValue == ProfileType.pet.rawValue ? 0.72 : 0.55
    }

    var accentBlue: Double {
        typeRawValue == ProfileType.pet.rawValue ? 0.96 : 0.66
    }
}
