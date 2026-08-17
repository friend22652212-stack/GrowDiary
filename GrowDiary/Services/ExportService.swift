import Foundation
import PDFKit
import UIKit

enum ExportService {
    static func exportProfileDiaryPDF(profile: Profile) -> URL? {
        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        let data = renderer.pdfData { context in
            context.beginPage()

            var y: CGFloat = 40
            let margin: CGFloat = 40
            let contentWidth = pageRect.width - margin * 2

            y = drawTitle(L10n.format("export.pdf.coverTitle", profile.name), at: y, margin: margin, width: contentWidth)
            y += 8
            y = drawSubtitle("\(profile.type.displayName) · \(profile.ageDescription)", at: y, margin: margin, width: contentWidth)
            y += 24

            for entry in profile.sortedEntries.reversed() {
                if y > pageRect.height - 120 {
                    context.beginPage()
                    y = 40
                }

                y = drawHeading(entry.title, at: y, margin: margin, width: contentWidth)
                y += 4
                y = drawSubtitle(
                    entry.date.formatted(date: .long, time: .shortened),
                    at: y,
                    margin: margin,
                    width: contentWidth
                )
                y += 8

                if !entry.content.isEmpty {
                    y = drawBody(entry.content, at: y, margin: margin, width: contentWidth)
                    y += 8
                }

                if !entry.tags.isEmpty {
                    let tagText = entry.tags.map(\.name).joined(separator: " · ")
                    y = drawSubtitle(L10n.format("export.pdf.tagsLine", tagText), at: y, margin: margin, width: contentWidth)
                    y += 8
                }

                y += 16
            }

            if profile.sortedEntries.isEmpty {
                _ = drawBody(L10n.string("export.pdf.noEntries"), at: y, margin: margin, width: contentWidth)
            }
        }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(L10n.format("export.pdf.filename", profile.name))

        do {
            try data.write(to: url)
            return url
        } catch {
            return nil
        }
    }

    private static func drawTitle(_ text: String, at y: CGFloat, margin: CGFloat, width: CGFloat) -> CGFloat {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 22),
            .foregroundColor: UIColor.black,
        ]
        return draw(text, at: y, margin: margin, width: width, attrs: attrs)
    }

    private static func drawHeading(_ text: String, at y: CGFloat, margin: CGFloat, width: CGFloat) -> CGFloat {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: UIColor.black,
        ]
        return draw(text, at: y, margin: margin, width: width, attrs: attrs)
    }

    private static func drawSubtitle(_ text: String, at y: CGFloat, margin: CGFloat, width: CGFloat) -> CGFloat {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.darkGray,
        ]
        return draw(text, at: y, margin: margin, width: width, attrs: attrs)
    }

    private static func drawBody(_ text: String, at y: CGFloat, margin: CGFloat, width: CGFloat) -> CGFloat {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.black,
        ]
        return draw(text, at: y, margin: margin, width: width, attrs: attrs)
    }

    private static func draw(
        _ text: String,
        at y: CGFloat,
        margin: CGFloat,
        width: CGFloat,
        attrs: [NSAttributedString.Key: Any]
    ) -> CGFloat {
        let bounding = (text as NSString).boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attrs,
            context: nil
        )
        (text as NSString).draw(
            in: CGRect(x: margin, y: y, width: width, height: bounding.height),
            withAttributes: attrs
        )
        return y + bounding.height
    }
}
