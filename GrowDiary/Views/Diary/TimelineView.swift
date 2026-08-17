import SwiftData
import SwiftUI

struct TimelineView: View {
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @Query(sort: \DiaryEntry.date, order: .reverse) private var entries: [DiaryEntry]

    private var accessibleEntries: [DiaryEntry] {
        PremiumAccess.accessibleEntries(from: entries, isPremium: subscriptionManager.isPremium)
    }

    private var lockedEntryCount: Int {
        PremiumAccess.lockedEntryCount(in: entries, isPremium: subscriptionManager.isPremium)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ScreenBackground()

                Group {
                    if accessibleEntries.isEmpty {
                        if lockedEntryCount > 0 {
                            VStack(spacing: 20) {
                                DiaryHistoryLockedView {
                                    subscriptionManager.showingPaywall = true
                                }
                            }
                            .padding()
                        } else {
                            EmptyStateView(
                                systemImage: "clock",
                                title: L10n.string("timeline.empty.title"),
                                message: L10n.string("timeline.empty.message")
                            )
                        }
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 14) {
                                DiaryHistoryUpgradeBanner(lockedEntryCount: lockedEntryCount) {
                                    subscriptionManager.showingPaywall = true
                                }

                                ForEach(accessibleEntries) { entry in
                                    NavigationLink {
                                        DiaryEntryDetailView(entry: entry)
                                    } label: {
                                        TimelineRowView(entry: entry)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
            .navigationTitle(L10n.string("timeline.navigationTitle"))
        }
    }
}

struct TimelineRowView: View {
    let entry: DiaryEntry

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            if let profile = entry.profile {
                ProfileAvatarView(profile: profile, size: 44)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline) {
                    Text(entry.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Spacer()
                    Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let profile = entry.profile {
                    Text(profile.name)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(AppTheme.tint(for: profile.type))
                }

                if !entry.content.isEmpty {
                    Text(entry.content)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                if !entry.tags.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(entry.tags.prefix(3)) { tag in
                            TagChipView(tag: tag)
                        }
                    }
                }

                if let firstPhoto = entry.sortedPhotos.first,
                   let image = PhotoStorageService.loadImage(fileName: firstPhoto.fileName) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 84, height: 84)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous))
                }
            }
        }
        .cardStyle()
    }
}

#Preview {
    TimelineView()
        .modelContainer(for: [Profile.self, DiaryEntry.self, PhotoAttachment.self], inMemory: true)
        .environmentObject(SubscriptionManager.shared)
}
