import SwiftData

enum ModelContainerProvider {
    static let schema = Schema([
        Profile.self,
        DiaryEntry.self,
        PhotoAttachment.self,
        GrowthMetric.self,
        Milestone.self,
        DiaryTag.self,
    ])

    static let shared: ModelContainer = {
        let cloudKitDatabase: ModelConfiguration.CloudKitDatabase =
            AppSettings.isCloudSyncEnabled
            ? .private(CloudSyncConstants.containerIdentifier)
            : .none

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: cloudKitDatabase
        )

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create database: \(error.localizedDescription)")
        }
    }()

    static func previewContainer(inMemory: Bool = true) -> ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: inMemory)
        return try! ModelContainer(for: schema, configurations: [configuration])
    }
}
