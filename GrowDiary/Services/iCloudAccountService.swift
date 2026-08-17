import Foundation

enum iCloudAccountService {
    static var isSignedIn: Bool {
        FileManager.default.ubiquityIdentityToken != nil
    }

    static var syncStatusDescription: String {
        guard AppSettings.isCloudSyncEnabled else {
            return L10n.string("sync.status.disabled")
        }
        guard isSignedIn else {
            return L10n.string("sync.status.notSignedIn")
        }
        return L10n.string("sync.status.enabled")
    }
}
