import Foundation
import SwiftData

@Model
final class PhotoAttachment {
    var id: UUID
    var fileName: String
    var caption: String
    var sortOrder: Int
    var entry: DiaryEntry?

    init(fileName: String, caption: String = "", sortOrder: Int = 0) {
        id = UUID()
        self.fileName = fileName
        self.caption = caption
        self.sortOrder = sortOrder
    }
}
