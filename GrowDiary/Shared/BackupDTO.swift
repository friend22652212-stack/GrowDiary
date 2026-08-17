import Foundation

struct GrowDiaryBackup: Codable {
    static let currentVersion = 1

    let version: Int
    let exportedAt: Date
    let profiles: [ProfileBackup]
    let diaryEntries: [DiaryEntryBackup]
    let tags: [DiaryTagBackup]
    let growthMetrics: [GrowthMetricBackup]
    let milestones: [MilestoneBackup]
}

struct ProfileBackup: Codable {
    let id: UUID
    let name: String
    let typeRawValue: String
    let birthDate: Date
    let notes: String
    let avatarPhotoPath: String?
    let createdAt: Date
}

struct DiaryEntryBackup: Codable {
    let id: UUID
    let title: String
    let content: String
    let date: Date
    let createdAt: Date
    let profileID: UUID?
    let tagIDs: [UUID]
    let photos: [PhotoAttachmentBackup]
}

struct PhotoAttachmentBackup: Codable {
    let id: UUID
    let fileName: String
    let caption: String
    let sortOrder: Int
}

struct DiaryTagBackup: Codable {
    let id: UUID
    let name: String
    let colorHex: String
}

struct GrowthMetricBackup: Codable {
    let id: UUID
    let typeRawValue: String
    let value: Double
    let date: Date
    let notes: String
    let createdAt: Date
    let profileID: UUID?
}

struct MilestoneBackup: Codable {
    let id: UUID
    let title: String
    let achievedDate: Date?
    let isCompleted: Bool
    let templateId: String?
    let notes: String
    let sortOrder: Int
    let createdAt: Date
    let profileID: UUID?
}
