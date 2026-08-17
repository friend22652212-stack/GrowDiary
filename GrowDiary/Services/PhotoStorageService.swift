import Foundation
import UIKit

enum PhotoStorageService {
    private static let folderName = "GrowDiaryPhotos"

    static var usesCloudStorage: Bool {
        AppSettings.isCloudSyncEnabled && iCloudAccountService.isSignedIn
    }

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
        for url in candidateURLs(for: fileName) where FileManager.default.fileExists(atPath: url.path) {
            if let image = UIImage(contentsOfFile: url.path) {
                return image
            }
        }
        return nil
    }

    static func deleteImage(fileName: String) {
        for url in candidateURLs(for: fileName) where FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.removeItem(at: url)
        }
    }

    static func photoData(fileName: String) -> Data? {
        for url in candidateURLs(for: fileName) where FileManager.default.fileExists(atPath: url.path) {
            if let data = try? Data(contentsOf: url) {
                return data
            }
        }
        return nil
    }

    static func savePhotoData(_ data: Data, fileName: String) throws {
        let directory = try photosDirectory(createIfNeeded: true)
        let url = directory.appendingPathComponent(fileName)
        try data.write(to: url, options: .atomic)
    }

    static func migrateLocalPhotosToCloudIfNeeded() {
        guard usesCloudStorage else { return }
        guard !AppSettings.hasMigratedPhotosToCloud else { return }

        do {
            let localDirectory = try localPhotosDirectory(createIfNeeded: false)
            let cloudDirectory = try cloudPhotosDirectory(createIfNeeded: true)
            let fileNames = try FileManager.default.contentsOfDirectory(atPath: localDirectory.path)

            for fileName in fileNames {
                let source = localDirectory.appendingPathComponent(fileName)
                let destination = cloudDirectory.appendingPathComponent(fileName)
                guard !FileManager.default.fileExists(atPath: destination.path) else { continue }
                try FileManager.default.copyItem(at: source, to: destination)
            }

            AppSettings.hasMigratedPhotosToCloud = true
        } catch {
            // iCloud container may not be ready; retry on next launch
        }
    }

    private static func photoURL(for fileName: String) throws -> URL {
        let directory = try photosDirectory(createIfNeeded: true)
        return directory.appendingPathComponent(fileName)
    }

    private static func candidateURLs(for fileName: String) -> [URL] {
        var urls: [URL] = []
        if let primary = try? photosDirectory(createIfNeeded: false) {
            urls.append(primary.appendingPathComponent(fileName))
        }
        if let local = try? localPhotosDirectory(createIfNeeded: false) {
            let localURL = local.appendingPathComponent(fileName)
            if !urls.contains(localURL) {
                urls.append(localURL)
            }
        }
        if let cloud = try? cloudPhotosDirectory(createIfNeeded: false) {
            let cloudURL = cloud.appendingPathComponent(fileName)
            if !urls.contains(cloudURL) {
                urls.append(cloudURL)
            }
        }
        return urls
    }

    private static func photosDirectory(createIfNeeded: Bool) throws -> URL {
        if usesCloudStorage {
            return try cloudPhotosDirectory(createIfNeeded: createIfNeeded)
        }
        return try localPhotosDirectory(createIfNeeded: createIfNeeded)
    }

    private static func localPhotosDirectory(createIfNeeded: Bool) throws -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directory = documents.appendingPathComponent(folderName, isDirectory: true)

        if createIfNeeded, !FileManager.default.fileExists(atPath: directory.path) {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }

        return directory
    }

    private static func cloudPhotosDirectory(createIfNeeded: Bool) throws -> URL {
        guard let containerURL = FileManager.default.url(
            forUbiquityContainerIdentifier: CloudSyncConstants.containerIdentifier
        ) else {
            throw PhotoStorageError.cloudUnavailable
        }

        let directory = containerURL
            .appendingPathComponent("Documents", isDirectory: true)
            .appendingPathComponent(folderName, isDirectory: true)

        if createIfNeeded, !FileManager.default.fileExists(atPath: directory.path) {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }

        return directory
    }
}

enum PhotoStorageError: LocalizedError {
    case encodingFailed
    case cloudUnavailable

    var errorDescription: String? {
        switch self {
        case .encodingFailed: L10n.string("error.photo.encodingFailed")
        case .cloudUnavailable: L10n.string("error.photo.cloudUnavailable")
        }
    }
}
