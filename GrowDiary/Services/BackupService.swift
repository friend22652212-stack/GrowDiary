import Foundation
import SwiftData

enum BackupImportMode {
    case merge
    case replace
}

enum BackupService {
    private static let manifestFileName = "manifest.json"
    private static let photosFolderName = "photos"

    static func exportBackup(modelContext: ModelContext) throws -> URL {
        let profiles = try modelContext.fetch(FetchDescriptor<Profile>())
        let entries = try modelContext.fetch(FetchDescriptor<DiaryEntry>())
        let tags = try modelContext.fetch(FetchDescriptor<DiaryTag>())
        let metrics = try modelContext.fetch(FetchDescriptor<GrowthMetric>())
        let milestones = try modelContext.fetch(FetchDescriptor<Milestone>())

        let backup = GrowDiaryBackup(
            version: GrowDiaryBackup.currentVersion,
            exportedAt: .now,
            profiles: profiles.map(profileBackup(from:)),
            diaryEntries: entries.map(entryBackup(from:)),
            tags: tags.map(tagBackup(from:)),
            growthMetrics: metrics.map(metricBackup(from:)),
            milestones: milestones.map(milestoneBackup(from:))
        )

        let fileManager = FileManager.default
        let tempRoot = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        let photosDirectory = tempRoot.appendingPathComponent(photosFolderName, isDirectory: true)
        try fileManager.createDirectory(at: photosDirectory, withIntermediateDirectories: true)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let manifestData = try encoder.encode(backup)
        try manifestData.write(to: tempRoot.appendingPathComponent(manifestFileName), options: .atomic)

        var photoNames = Set<String>()
        for profile in profiles {
            if let path = profile.avatarPhotoPath {
                photoNames.insert(path)
            }
        }
        for entry in entries {
            for photo in entry.photos {
                photoNames.insert(photo.fileName)
            }
        }

        for fileName in photoNames {
            guard let data = PhotoStorageService.photoData(fileName: fileName) else { continue }
            try data.write(to: photosDirectory.appendingPathComponent(fileName), options: .atomic)
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        let zipURL = fileManager.temporaryDirectory
            .appendingPathComponent("GrowDiary-\(formatter.string(from: .now)).growdiary")

        try ZipArchiveHelper.createZip(from: tempRoot, to: zipURL)
        try? fileManager.removeItem(at: tempRoot)
        return zipURL
    }

    static func importBackup(
        from url: URL,
        modelContext: ModelContext,
        mode: BackupImportMode
    ) throws -> BackupImportSummary {
        let fileManager = FileManager.default
        let accessGranted = url.startAccessingSecurityScopedResource()
        defer {
            if accessGranted {
                url.stopAccessingSecurityScopedResource()
            }
        }

        let tempRoot = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try ZipArchiveHelper.unzip(from: url, to: tempRoot)

        let manifestURL = tempRoot.appendingPathComponent(manifestFileName)
        guard fileManager.fileExists(atPath: manifestURL.path) else {
            throw BackupError.invalidArchive
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let backup = try decoder.decode(GrowDiaryBackup.self, from: Data(contentsOf: manifestURL))

        guard backup.version <= GrowDiaryBackup.currentVersion else {
            throw BackupError.unsupportedVersion
        }

        if mode == .replace {
            try deleteAllData(modelContext: modelContext)
        }

        let existingProfileIDs = Set(try modelContext.fetch(FetchDescriptor<Profile>()).map(\.id))
        let existingEntryIDs = Set(try modelContext.fetch(FetchDescriptor<DiaryEntry>()).map(\.id))
        let existingTagIDs = Set(try modelContext.fetch(FetchDescriptor<DiaryTag>()).map(\.id))
        let existingMetricIDs = Set(try modelContext.fetch(FetchDescriptor<GrowthMetric>()).map(\.id))
        let existingMilestoneIDs = Set(try modelContext.fetch(FetchDescriptor<Milestone>()).map(\.id))

        var importedProfiles = 0
        var importedEntries = 0
        var importedTags = 0
        var importedMetrics = 0
        var importedMilestones = 0
        var importedPhotos = 0

        var profileMap: [UUID: Profile] = [:]
        for existing in try modelContext.fetch(FetchDescriptor<Profile>()) {
            profileMap[existing.id] = existing
        }

        var tagMap: [UUID: DiaryTag] = [:]
        for existing in try modelContext.fetch(FetchDescriptor<DiaryTag>()) {
            tagMap[existing.id] = existing
        }

        for tagBackup in backup.tags where !existingTagIDs.contains(tagBackup.id) {
            let tag = DiaryTag(name: tagBackup.name, colorHex: tagBackup.colorHex)
            tag.id = tagBackup.id
            modelContext.insert(tag)
            tagMap[tag.id] = tag
            importedTags += 1
        }

        for profileBackup in backup.profiles where !existingProfileIDs.contains(profileBackup.id) {
            let profile = Profile(
                name: profileBackup.name,
                type: ProfileType(rawValue: profileBackup.typeRawValue) ?? .baby,
                birthDate: profileBackup.birthDate,
                notes: profileBackup.notes,
                avatarPhotoPath: profileBackup.avatarPhotoPath
            )
            profile.id = profileBackup.id
            profile.createdAt = profileBackup.createdAt
            modelContext.insert(profile)
            profileMap[profile.id] = profile
            importedProfiles += 1
        }

        for metricBackup in backup.growthMetrics where !existingMetricIDs.contains(metricBackup.id) {
            let metric = GrowthMetric(
                type: GrowthMetricType(rawValue: metricBackup.typeRawValue) ?? .weight,
                value: metricBackup.value,
                date: metricBackup.date,
                notes: metricBackup.notes,
                profile: metricBackup.profileID.flatMap { profileMap[$0] }
            )
            metric.id = metricBackup.id
            metric.createdAt = metricBackup.createdAt
            modelContext.insert(metric)
            if let profileID = metricBackup.profileID, let profile = profileMap[profileID] {
                profile.growthMetrics.append(metric)
            }
            importedMetrics += 1
        }

        for milestoneBackup in backup.milestones where !existingMilestoneIDs.contains(milestoneBackup.id) {
            let milestone = Milestone(
                title: milestoneBackup.title,
                templateId: milestoneBackup.templateId,
                sortOrder: milestoneBackup.sortOrder,
                profile: milestoneBackup.profileID.flatMap { profileMap[$0] }
            )
            milestone.id = milestoneBackup.id
            milestone.achievedDate = milestoneBackup.achievedDate
            milestone.isCompleted = milestoneBackup.isCompleted
            milestone.notes = milestoneBackup.notes
            milestone.createdAt = milestoneBackup.createdAt
            modelContext.insert(milestone)
            if let profileID = milestoneBackup.profileID, let profile = profileMap[profileID] {
                profile.milestones.append(milestone)
            }
            importedMilestones += 1
        }

        let photosDirectory = tempRoot.appendingPathComponent(photosFolderName, isDirectory: true)
        for entryBackup in backup.diaryEntries where !existingEntryIDs.contains(entryBackup.id) {
            let entry = DiaryEntry(
                title: entryBackup.title,
                content: entryBackup.content,
                date: entryBackup.date,
                profile: entryBackup.profileID.flatMap { profileMap[$0] }
            )
            entry.id = entryBackup.id
            entry.createdAt = entryBackup.createdAt
            entry.tags = entryBackup.tagIDs.compactMap { tagMap[$0] }

            for photoBackup in entryBackup.photos {
                let sourceURL = photosDirectory.appendingPathComponent(photoBackup.fileName)
                if fileManager.fileExists(atPath: sourceURL.path),
                   let data = try? Data(contentsOf: sourceURL) {
                    try PhotoStorageService.savePhotoData(data, fileName: photoBackup.fileName)
                    importedPhotos += 1
                }

                let attachment = PhotoAttachment(
                    fileName: photoBackup.fileName,
                    caption: photoBackup.caption,
                    sortOrder: photoBackup.sortOrder
                )
                attachment.id = photoBackup.id
                attachment.entry = entry
                entry.photos.append(attachment)
            }

            modelContext.insert(entry)
            if let profileID = entryBackup.profileID, let profile = profileMap[profileID] {
                profile.entries.append(entry)
            }
            importedEntries += 1
        }

        for profileBackup in backup.profiles {
            guard let avatar = profileBackup.avatarPhotoPath else { continue }
            let sourceURL = photosDirectory.appendingPathComponent(avatar)
            guard fileManager.fileExists(atPath: sourceURL.path),
                  let data = try? Data(contentsOf: sourceURL) else { continue }
            try PhotoStorageService.savePhotoData(data, fileName: avatar)
            importedPhotos += 1
        }

        try modelContext.save()
        try? fileManager.removeItem(at: tempRoot)

        return BackupImportSummary(
            profiles: importedProfiles,
            entries: importedEntries,
            tags: importedTags,
            metrics: importedMetrics,
            milestones: importedMilestones,
            photos: importedPhotos
        )
    }

    private static func deleteAllData(modelContext: ModelContext) throws {
        for entry in try modelContext.fetch(FetchDescriptor<DiaryEntry>()) {
            for photo in entry.photos {
                PhotoStorageService.deleteImage(fileName: photo.fileName)
            }
            modelContext.delete(entry)
        }

        for profile in try modelContext.fetch(FetchDescriptor<Profile>()) {
            if let avatar = profile.avatarPhotoPath {
                PhotoStorageService.deleteImage(fileName: avatar)
            }
            modelContext.delete(profile)
        }

        for tag in try modelContext.fetch(FetchDescriptor<DiaryTag>()) {
            modelContext.delete(tag)
        }

        for metric in try modelContext.fetch(FetchDescriptor<GrowthMetric>()) {
            modelContext.delete(metric)
        }

        for milestone in try modelContext.fetch(FetchDescriptor<Milestone>()) {
            modelContext.delete(milestone)
        }

        try modelContext.save()
    }

    private static func profileBackup(from profile: Profile) -> ProfileBackup {
        ProfileBackup(
            id: profile.id,
            name: profile.name,
            typeRawValue: profile.typeRawValue,
            birthDate: profile.birthDate,
            notes: profile.notes,
            avatarPhotoPath: profile.avatarPhotoPath,
            createdAt: profile.createdAt
        )
    }

    private static func entryBackup(from entry: DiaryEntry) -> DiaryEntryBackup {
        DiaryEntryBackup(
            id: entry.id,
            title: entry.title,
            content: entry.content,
            date: entry.date,
            createdAt: entry.createdAt,
            profileID: entry.profile?.id,
            tagIDs: entry.tags.map(\.id),
            photos: entry.sortedPhotos.map {
                PhotoAttachmentBackup(
                    id: $0.id,
                    fileName: $0.fileName,
                    caption: $0.caption,
                    sortOrder: $0.sortOrder
                )
            }
        )
    }

    private static func tagBackup(from tag: DiaryTag) -> DiaryTagBackup {
        DiaryTagBackup(id: tag.id, name: tag.name, colorHex: tag.colorHex)
    }

    private static func metricBackup(from metric: GrowthMetric) -> GrowthMetricBackup {
        GrowthMetricBackup(
            id: metric.id,
            typeRawValue: metric.typeRawValue,
            value: metric.value,
            date: metric.date,
            notes: metric.notes,
            createdAt: metric.createdAt,
            profileID: metric.profile?.id
        )
    }

    private static func milestoneBackup(from milestone: Milestone) -> MilestoneBackup {
        MilestoneBackup(
            id: milestone.id,
            title: milestone.title,
            achievedDate: milestone.achievedDate,
            isCompleted: milestone.isCompleted,
            templateId: milestone.templateId,
            notes: milestone.notes,
            sortOrder: milestone.sortOrder,
            createdAt: milestone.createdAt,
            profileID: milestone.profile?.id
        )
    }
}

struct BackupImportSummary {
    let profiles: Int
    let entries: Int
    let tags: Int
    let metrics: Int
    let milestones: Int
    let photos: Int

    var isEmpty: Bool {
        profiles + entries + tags + metrics + milestones + photos == 0
    }
}

enum BackupError: LocalizedError {
    case invalidArchive
    case unsupportedVersion

    var errorDescription: String? {
        switch self {
        case .invalidArchive: L10n.string("backup.error.invalidArchive")
        case .unsupportedVersion: L10n.string("backup.error.unsupportedVersion")
        }
    }
}
