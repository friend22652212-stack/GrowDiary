import Foundation
import SwiftData

@Model
final class Milestone {
    var id: UUID
    var title: String
    var achievedDate: Date?
    var isCompleted: Bool
    var templateId: String?
    var notes: String
    var sortOrder: Int
    var createdAt: Date
    var profile: Profile?

    init(
        title: String,
        templateId: String? = nil,
        sortOrder: Int = 0,
        profile: Profile? = nil
    ) {
        id = UUID()
        self.title = title
        achievedDate = nil
        isCompleted = false
        self.templateId = templateId
        notes = ""
        self.sortOrder = sortOrder
        createdAt = Date()
        self.profile = profile
    }
}

extension Milestone {
    var displayTitle: String {
        if let templateId,
           let template = MilestoneTemplateProvider.template(withId: templateId) {
            return template.title
        }
        return title
    }
}
