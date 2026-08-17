import Foundation
import SwiftData

struct MilestoneTemplate: Identifiable {
    let id: String
    let titleKey: String
    let systemImage: String

    var title: String { L10n.string(titleKey) }
}

enum MilestoneTemplateProvider {
    static func templates(for type: ProfileType) -> [MilestoneTemplate] {
        switch type {
        case .baby: babyTemplates
        case .pet: petTemplates
        }
    }

    static func template(withId id: String) -> MilestoneTemplate? {
        babyTemplates.first { $0.id == id } ?? petTemplates.first { $0.id == id }
    }

    private static let babyTemplates: [MilestoneTemplate] = [
        MilestoneTemplate(id: "baby_smile", titleKey: "milestone.template.baby.smile", systemImage: "face.smiling"),
        MilestoneTemplate(id: "baby_roll", titleKey: "milestone.template.baby.roll", systemImage: "arrow.triangle.2.circlepath"),
        MilestoneTemplate(id: "baby_sit", titleKey: "milestone.template.baby.sit", systemImage: "figure.seated.side"),
        MilestoneTemplate(id: "baby_tooth", titleKey: "milestone.template.baby.tooth", systemImage: "mouth"),
        MilestoneTemplate(id: "baby_crawl", titleKey: "milestone.template.baby.crawl", systemImage: "figure.walk"),
        MilestoneTemplate(id: "baby_stand", titleKey: "milestone.template.baby.stand", systemImage: "figure.stand"),
        MilestoneTemplate(id: "baby_walk", titleKey: "milestone.template.baby.walk", systemImage: "figure.walk.motion"),
        MilestoneTemplate(id: "baby_word", titleKey: "milestone.template.baby.firstWord", systemImage: "bubble.left"),
        MilestoneTemplate(id: "baby_solid", titleKey: "milestone.template.baby.solidFood", systemImage: "fork.knife"),
        MilestoneTemplate(id: "baby_sleep", titleKey: "milestone.template.baby.sleepThrough", systemImage: "moon.zzz"),
    ]

    private static let petTemplates: [MilestoneTemplate] = [
        MilestoneTemplate(id: "pet_home", titleKey: "milestone.template.pet.home", systemImage: "house"),
        MilestoneTemplate(id: "pet_bath", titleKey: "milestone.template.pet.bath", systemImage: "drop"),
        MilestoneTemplate(id: "pet_vaccine", titleKey: "milestone.template.pet.vaccine", systemImage: "cross.case"),
        MilestoneTemplate(id: "pet_walk", titleKey: "milestone.template.pet.walk", systemImage: "figure.walk"),
        MilestoneTemplate(id: "pet_trick", titleKey: "milestone.template.pet.trick", systemImage: "star"),
        MilestoneTemplate(id: "pet_friend", titleKey: "milestone.template.pet.friend", systemImage: "pawprint.2"),
        MilestoneTemplate(id: "pet_groom", titleKey: "milestone.template.pet.groom", systemImage: "scissors"),
    ]

    static func seedMilestones(for profile: Profile, context: ModelContext) {
        let existingIds = Set(profile.milestones.compactMap(\.templateId))
        let templates = templates(for: profile.type)

        for (index, template) in templates.enumerated() where !existingIds.contains(template.id) {
            let milestone = Milestone(
                title: template.title,
                templateId: template.id,
                sortOrder: index,
                profile: profile
            )
            context.insert(milestone)
            profile.milestones.append(milestone)
        }
    }
}
