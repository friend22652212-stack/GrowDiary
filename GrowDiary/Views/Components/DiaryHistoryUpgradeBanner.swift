import SwiftUI

struct DiaryHistoryUpgradeBanner: View {
    let lockedEntryCount: Int
    let onUpgrade: () -> Void

    var body: some View {
        if lockedEntryCount > 0 {
            Button(action: onUpgrade) {
                HStack(spacing: 12) {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(AppTheme.babyPrimary)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(L10n.format("premium.diary.lockedBanner.title", lockedEntryCount))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                        Text(L10n.string("premium.diary.lockedBanner.subtitle"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
                .padding(14)
                .background(AppTheme.cardBackground, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
            }
            .buttonStyle(.plain)
        }
    }
}

struct DiaryHistoryLockedView: View {
    let onUpgrade: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.fill")
                .font(.system(size: 44))
                .foregroundStyle(AppTheme.babyPrimary)

            Text(L10n.string("premium.diary.lockedDetail.title"))
                .font(.title3.bold())
                .multilineTextAlignment(.center)

            Text(L10n.string("premium.diary.lockedDetail.message"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button(action: onUpgrade) {
                Text(L10n.string("premium.upgrade"))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.babyPrimary)
        }
        .padding(24)
    }
}
