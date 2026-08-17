import Foundation
import SwiftData

@Model
final class DiaryEntry {
    var id: UUID
    var title: String
    var content: String
    var date: Date
    var createdAt: Date
    var profile: Profile?
    @Relationship(deleteRule: .nullify)
    var tags: [DiaryTag]
    @Relationship(deleteRule: .cascade, inverse: \PhotoAttachment.entry)
    var photos: [PhotoAttachment]

    init(
        title: String,
        content: String,
        date: Date = .now,
        profile: Profile? = nil
    ) {
        id = UUID()
        self.title = title
        self.content = content
        self.date = date
        createdAt = Date()
        self.profile = profile
        tags = []
        photos = []
    }

    var tagNames: String {
        tags.map(\.name).joined(separator: " ")
    }

    var sortedPhotos: [PhotoAttachment] {
        photos.sorted { $0.sortOrder < $1.sortOrder }
    }
}
