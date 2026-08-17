import SwiftData
import SwiftUI

struct ProfilesListView: View {
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @Query(sort: \Profile.createdAt, order: .reverse) private var profiles: [Profile]

    @State private var showingAddProfile = false

    var body: some View {
        NavigationStack {
            ZStack {
                ScreenBackground()

                Group {
                    if profiles.isEmpty {
                        EmptyStateView(
                            systemImage: "person.crop.circle.badge.plus",
                            title: L10n.string("profiles.empty.title"),
                            message: L10n.string("profiles.empty.message")
                        )
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 14) {
                                ForEach(profiles) { profile in
                                    NavigationLink(value: profile) {
                                        ProfileRowView(profile: profile)
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
            .navigationTitle(L10n.string("profiles.navigationTitle"))
            .navigationDestination(for: Profile.self) { profile in
                ProfileDetailView(profile: profile)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if subscriptionManager.canAddProfile(currentCount: profiles.count) {
                            showingAddProfile = true
                        } else {
                            subscriptionManager.showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, AppTheme.babyPrimary)
                    }
                    .accessibilityLabel(L10n.string("profiles.accessibility.add"))
                }
            }
            .sheet(isPresented: $showingAddProfile) {
                AddEditProfileView()
            }
        }
    }
}

struct ProfileRowView: View {
    let profile: Profile

    var body: some View {
        HStack(spacing: 16) {
            ProfileAvatarView(profile: profile, size: 64)

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text(profile.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    ProfileTypeBadge(type: profile.type)
                }

                Text(profile.ageDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    Label(L10n.format("profiles.stats.diaryCount", profile.entries.count), systemImage: "book.fill")
                    Label(L10n.format("profiles.stats.milestoneProgress", profile.completedMilestoneCount, profile.milestones.count), systemImage: "flag.fill")
                }
                .font(.caption)
                .foregroundStyle(AppTheme.tint(for: profile.type))
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .cardStyle()
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .fill(AppTheme.tint(for: profile.type))
                .frame(width: 4)
                .padding(.vertical, 8)
        }
    }
}

#Preview {
    ProfilesListView()
        .modelContainer(for: [Profile.self, DiaryEntry.self, PhotoAttachment.self], inMemory: true)
        .environmentObject(SubscriptionManager.shared)
}