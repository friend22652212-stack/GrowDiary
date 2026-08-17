import Foundation
import UIKit
import WidgetKit

enum WidgetSnapshotService {
    static func refreshSnapshots(for profiles: [Profile]) {
        guard let defaults = UserDefaults(suiteName: AppGroupConstants.identifier) else { return }

        guard WidgetSettings.isEnabled else {
            defaults.removeObject(forKey: AppGroupConstants.snapshotsKey)
            WidgetCenter.shared.reloadAllTimelines()
            return
        }

        let snapshots = profiles.map { makeSnapshot(for: $0) }
        if let data = try? JSONEncoder().encode(snapshots) {
            defaults.set(data, forKey: AppGroupConstants.snapshotsKey)
        }

        WidgetCenter.shared.reloadAllTimelines()
    }

    private static func makeSnapshot(for profile: Profile) -> WidgetProfileSnapshot {
        let latestEntry = profile.sortedEntries.first
        let hasThumbnail = saveThumbnail(for: profile)

        return WidgetProfileSnapshot(
            id: profile.id,
            name: profile.name,
            typeRawValue: profile.typeRawValue,
            birthDate: profile.birthDate,
            ageDescription: profile.ageDescription,
            latestEntryTitle: latestEntry?.title,
            latestEntryDate: latestEntry?.date,
            hasThumbnail: hasThumbnail,
            updatedAt: .now
        )
    }

    private static func saveThumbnail(for profile: Profile) -> Bool {
        guard let image = resolveDisplayImage(for: profile) else {
            removeThumbnail(for: profile.id)
            return false
        }

        guard let directory = thumbnailsDirectory() else { return false }

        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            let url = directory.appendingPathComponent("\(profile.id.uuidString).jpg")
            let resized = resize(image, maxSide: 360)
            guard let data = resized.jpegData(compressionQuality: 0.82) else { return false }
            try data.write(to: url, options: .atomic)
            return true
        } catch {
            return false
        }
    }

    private static func resolveDisplayImage(for profile: Profile) -> UIImage? {
        for entry in profile.sortedEntries {
            for photo in entry.sortedPhotos {
                if let image = PhotoStorageService.loadImage(fileName: photo.fileName) {
                    return image
                }
            }
        }

        if let avatarPath = profile.avatarPhotoPath {
            return PhotoStorageService.loadImage(fileName: avatarPath)
        }

        return nil
    }

    private static func removeThumbnail(for profileID: UUID) {
        guard let url = thumbnailURL(for: profileID) else { return }
        try? FileManager.default.removeItem(at: url)
    }

    private static func thumbnailURL(for profileID: UUID) -> URL? {
        thumbnailsDirectory()?.appendingPathComponent("\(profileID.uuidString).jpg")
    }

    private static func thumbnailsDirectory() -> URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: AppGroupConstants.identifier)?
            .appendingPathComponent(AppGroupConstants.thumbnailsFolderName, isDirectory: true)
    }

    private static func resize(_ image: UIImage, maxSide: CGFloat) -> UIImage {
        let longest = max(image.size.width, image.size.height)
        guard longest > maxSide else { return image }

        let scale = maxSide / longest
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
