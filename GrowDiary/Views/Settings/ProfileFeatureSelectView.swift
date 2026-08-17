import SwiftData
import SwiftUI

/// Select a profile, then open the chosen feature tab
struct ProfileFeatureSelectView: View {
    @Query(sort: \Profile.name) private var profiles: [Profile]

    let title: String
    let emptyMessage: String
    let destinationTab: ProfileDetailTab

    var body: some View {
        Group {
            if profiles.isEmpty {
                EmptyStateView(
                    systemImage: "person.crop.circle.badge.plus",
                    title: L10n.string("profiles.empty.title"),
                    message: emptyMessage
                )
            } else {
                List(profiles) { profile in
                    NavigationLink {
                        ProfileDetailView(profile: profile, initialTab: destinationTab)
                    } label: {
                        HStack(spacing: 12) {
                            ProfileAvatarView(profile: profile, size: 44)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(profile.name)
                                    .font(.headline)
                                Text(profile.type.displayName)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// Select a profile to export PDF
struct ProfileExportSelectView: View {
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @Query(sort: \Profile.name) private var profiles: [Profile]

    @State private var exportURL: URL?
    @State private var showingExportSheet = false

    var body: some View {
        Group {
            if profiles.isEmpty {
                EmptyStateView(
                    systemImage: "doc.richtext",
                    title: L10n.string("export.empty.title"),
                    message: L10n.string("export.empty.message")
                )
            } else {
                List(profiles) { profile in
                    Button {
                        exportProfile(profile)
                    } label: {
                        HStack(spacing: 12) {
                            ProfileAvatarView(profile: profile, size: 44)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(profile.name)
                                    .font(.headline)
                                Text(L10n.format("export.profile.diaryCount", profile.entries.count))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "square.and.arrow.up")
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle(L10n.string("export.navigationTitle"))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingExportSheet) {
            if let exportURL {
                ShareSheet(items: [exportURL])
            }
        }
    }

    private func exportProfile(_ profile: Profile) {
        guard subscriptionManager.requirePremium() else { return }
        if let url = ExportService.exportProfileDiaryPDF(profile: profile) {
            exportURL = url
            showingExportSheet = true
        }
    }
}
