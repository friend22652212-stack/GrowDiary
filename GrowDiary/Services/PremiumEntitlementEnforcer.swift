import CoreSpotlight
import Foundation

enum PremiumEntitlementEnforcer {
    /// 訂閱到期或未訂閱時，關閉需 Premium 的設定（不刪除使用者資料）
    static func applyFreeTierRestrictions() {
        if AppSettings.isAppLockEnabled {
            AppSettings.isAppLockEnabled = false
            Task { @MainActor in
                AppLockManager.shared.unlockIfDisabled()
            }
        }

        if AppSettings.isCloudSyncEnabled {
            AppSettings.isCloudSyncEnabled = false
        }

        if AppSettings.isSpotlightEnabled {
            AppSettings.isSpotlightEnabled = false
            CSSearchableIndex.default().deleteSearchableItems(
                withDomainIdentifiers: [SpotlightIndexingService.domainIdentifier]
            )
        }
    }
}
