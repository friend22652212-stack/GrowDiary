import CoreSpotlight
import Foundation

@MainActor
final class SpotlightNavigationState: ObservableObject {
    static let shared = SpotlightNavigationState()

    @Published var pendingEntryID: UUID?
    @Published var pendingProfileID: UUID?

    func openEntry(id: UUID) {
        pendingEntryID = id
    }

    func openProfile(id: UUID) {
        pendingProfileID = id
    }

    func clearPendingEntry() {
        pendingEntryID = nil
    }

    func clearPendingProfile() {
        pendingProfileID = nil
    }
}

enum SpotlightIndexingService {
    static let domainIdentifier = "com.kao.growdiary"

    static func indexAll(profiles: [Profile], entries: [DiaryEntry]) {
        guard AppSettings.isSpotlightEnabled else {
            CSSearchableIndex.default().deleteSearchableItems(withDomainIdentifiers: [domainIdentifier])
            return
        }

        var items: [CSSearchableItem] = []
        for profile in profiles {
            items.append(makeProfileItem(profile))
        }
        for entry in entries {
            items.append(makeEntryItem(entry))
        }

        CSSearchableIndex.default().indexSearchableItems(items)
    }

    static func indexEntry(_ entry: DiaryEntry) {
        guard AppSettings.isSpotlightEnabled else { return }
        CSSearchableIndex.default().indexSearchableItems([makeEntryItem(entry)])
    }

    static func removeEntry(_ entry: DiaryEntry) {
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [entryIdentifier(entry.id)])
    }

    static func indexProfile(_ profile: Profile) {
        guard AppSettings.isSpotlightEnabled else { return }
        CSSearchableIndex.default().indexSearchableItems([makeProfileItem(profile)])
    }

    static func removeProfile(_ profile: Profile) {
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [profileIdentifier(profile.id)])
    }

    @MainActor
    static func handle(userActivity: NSUserActivity) -> Bool {
        guard userActivity.activityType == CSSearchableItemActionType,
              let identifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String else {
            return false
        }

        if identifier.hasPrefix("entry-"), let uuid = UUID(uuidString: String(identifier.dropFirst(6))) {
            SpotlightNavigationState.shared.openEntry(id: uuid)
            return true
        }

        if identifier.hasPrefix("profile-"), let uuid = UUID(uuidString: String(identifier.dropFirst(8))) {
            SpotlightNavigationState.shared.openProfile(id: uuid)
            return true
        }

        return false
    }

    private static func makeEntryItem(_ entry: DiaryEntry) -> CSSearchableItem {
        let attributeSet = CSSearchableItemAttributeSet(contentType: .text)
        attributeSet.title = entry.title
        attributeSet.contentDescription = entry.content.isEmpty ? entry.profile?.name : entry.content
        attributeSet.keywords = entry.tags.map(\.name)
        if let profile = entry.profile {
            attributeSet.keywords?.append(profile.name)
        }

        let item = CSSearchableItem(
            uniqueIdentifier: entryIdentifier(entry.id),
            domainIdentifier: domainIdentifier,
            attributeSet: attributeSet
        )
        return item
    }

    private static func makeProfileItem(_ profile: Profile) -> CSSearchableItem {
        let attributeSet = CSSearchableItemAttributeSet(contentType: .text)
        attributeSet.title = profile.name
        attributeSet.contentDescription = profile.notes.isEmpty
            ? profile.ageDescription
            : profile.notes
        attributeSet.keywords = [profile.type.displayName, L10n.string("spotlight.keyword.profile")]

        return CSSearchableItem(
            uniqueIdentifier: profileIdentifier(profile.id),
            domainIdentifier: domainIdentifier,
            attributeSet: attributeSet
        )
    }

    private static func entryIdentifier(_ id: UUID) -> String {
        "entry-\(id.uuidString)"
    }

    private static func profileIdentifier(_ id: UUID) -> String {
        "profile-\(id.uuidString)"
    }
}
