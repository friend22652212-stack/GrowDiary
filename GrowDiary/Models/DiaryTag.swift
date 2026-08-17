import Foundation
import SwiftData
import SwiftUI

@Model
final class DiaryTag {
    var id: UUID
    var name: String
    var colorHex: String
    @Relationship(inverse: \DiaryEntry.tags)
    var entries: [DiaryEntry]

    init(name: String, colorHex: String = "EB7299") {
        id = UUID()
        self.name = name
        self.colorHex = colorHex
        entries = []
    }

    var color: Color {
        Color(hex: colorHex) ?? AppTheme.accent
    }
}

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        guard hexSanitized.count == 6,
              let int = UInt64(hexSanitized, radix: 16) else { return nil }

        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
