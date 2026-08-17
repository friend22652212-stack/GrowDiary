import Foundation
import LocalAuthentication

@MainActor
final class AppLockManager: ObservableObject {
    static let shared = AppLockManager()

    @Published private(set) var isLocked = false
    @Published private(set) var biometryType: LABiometryType = .none

    private init() {
        refreshBiometryType()
    }

    var isAvailable: Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    func refreshBiometryType() {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        biometryType = context.biometryType
    }

    func lockIfNeeded() {
        guard AppSettings.isAppLockEnabled else {
            isLocked = false
            return
        }
        isLocked = true
    }

    func unlockIfDisabled() {
        guard !AppSettings.isAppLockEnabled else { return }
        isLocked = false
    }

    func authenticate() async -> Bool {
        guard AppSettings.isAppLockEnabled else {
            isLocked = false
            return true
        }

        let context = LAContext()
        context.localizedCancelTitle = L10n.string("applock.action.cancel")

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: L10n.string("applock.reason")
            )
            if success {
                isLocked = false
            }
            return success
        } catch {
            return false
        }
    }
}
