import SwiftUI

struct AppLockOverlay: View {
    @ObservedObject private var appLockManager = AppLockManager.shared

    var body: some View {
        ZStack {
            AppTheme.screenBackground
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: biometryIcon)
                    .font(.system(size: 56))
                    .foregroundStyle(AppTheme.babyPrimary)

                Text(L10n.string("applock.title"))
                    .font(.title2.bold())

                Text(L10n.string("applock.subtitle"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Button {
                    Task { await appLockManager.authenticate() }
                } label: {
                    Label(unlockLabel, systemImage: biometryIcon)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.babyPrimary)
                .padding(.horizontal, 40)
                .padding(.top, 8)
            }
        }
    }

    private var biometryIcon: String {
        switch appLockManager.biometryType {
        case .faceID: "faceid"
        case .touchID: "touchid"
        default: "lock.fill"
        }
    }

    private var unlockLabel: String {
        switch appLockManager.biometryType {
        case .faceID: L10n.string("applock.action.faceID")
        case .touchID: L10n.string("applock.action.touchID")
        default: L10n.string("applock.action.passcode")
        }
    }
}
