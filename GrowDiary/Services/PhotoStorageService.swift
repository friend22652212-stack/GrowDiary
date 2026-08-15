import Foundation
import UIKit

enum PhotoStorageService {
    private static let folderName = "GrowDiaryPhotos"

    static func saveImage(_ image: UIImage, compressionQuality: CGFloat = 0.85) throws -> String {
        let fileName = "\(UUID().uuidString).jpg"
        let url = try photoURL(for: fileName)

        guard let data = image.jpegData(compressionQuality: compressionQuality) else {
            throw PhotoStorageError.encodingFailed
        }

        try data.write(to: url, options: .atomic)
        return fileName
    }

    static func loadImage(fileName: String) -> UIImage? {
        guard let url = try? photoURL(for: fileName),
              FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }
        return UIImage(contentsOfFile: url.path)
    }

    static func deleteImage(fileName: String) {
        guard let url = try? photoURL(for: fileName) else { return }
        try? FileManager.default.removeItem(at: url)
    }

    private static func photoURL(for fileName: String) throws -> URL {
        let directory = try photosDirectory()
        return directory.appendingPathComponent(fileName)
    }

    private static func photosDirectory() throws -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directory = documents.appendingPathComponent(folderName, isDirectory: true)

        if !FileManager.default.fileExists(atPath: directory.path) {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }

        return directory
    }
}

enum PhotoStorageError: LocalizedError {
    case encodingFailed

    var errorDescription: String? {
        switch self {
        case .encodingFailed: "無法儲存照片，請再試一次。"
        }
    }
}
