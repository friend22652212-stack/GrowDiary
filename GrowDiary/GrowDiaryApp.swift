import SwiftData
import SwiftUI

@main
struct GrowDiaryApp: App {
    @StateObject private var languageManager = LanguageManager.shared
    @StateObject private var subscriptionManager = SubscriptionManager.shared

    init() {
        Bundle.setLanguage(AppLanguage.current)
        PhotoStorageService.migrateLocalPhotosToCloudIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .tint(AppTheme.babyPrimary)
                .environmentObject(languageManager)
                .environmentObject(subscriptionManager)
                .environment(\.locale, languageManager.current.locale)
                .id(languageManager.current)
        }
        .modelContainer(ModelContainerProvider.shared)
    }
}
