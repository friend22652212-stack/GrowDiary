import SwiftData
import SwiftUI

enum ProfileDetailTab: String, CaseIterable, Identifiable {
    case diary
    case growth
    case milestones

    var id: String { rawValue }

    var title: String {
        switch self {
        case .diary: L10n.string("profile.tab.diary")
        case .growth: L10n.string("profile.tab.growth")
        case .milestones: L10n.string("profile.tab.milestones")
        }
    }

    var systemImage: String {
        switch self {
        case .diary: "book.fill"
        case .growth: "chart.line.uptrend.xyaxis"
        case .milestones: "flag.fill"
        }
    }
}

struct ProfileDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @Bindable var profile: Profile

    @State private var selectedTab: ProfileDetailTab
    @State private var showingEditProfile = false
    @State private var showingAddEntry = false
    @State private var showingDeleteConfirmation = false
    @State private var exportURL: URL?
    @State private var showingExportSheet = false

    init(profile: Profile, initialTab: ProfileDetailTab = .diary) {
        _profile = Bindable(profile)
        _selectedTab = State(initialValue: initialTab)
    }

    var body: some View {
        ZStack {
            ScreenBackground()

            VStack(spacing: 0) {
                profileHeader
                    .padding(.horizontal)
                    .padding(.top, 8)

                Picker(L10n.string("profile.picker.tabs"), selection: $selectedTab) {
                    ForEach(ProfileDetailTab.allCases) { tab in
                        Label(tab.title, systemImage: tab.systemImage)
                            .tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 12)

                tabContent
            }
        }
        .navigationTitle(profile.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(L10n.string("profile.action.edit")) { showingEditProfile = true }
                    Button(L10n.string("profile.action.addDiary")) { showingAddEntry = true }
                    Button(L10n.string("profile.action.exportPDF")) { exportPDF() }
                    Divider()
                    Button(L10n.string("profile.action.delete"), role: .destructive) {
                        showingDeleteConfirmation = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEditProfile) {
            AddEditProfileView(profile: profile)
        }
        .sheet(isPresented: $showingAddEntry) {
            AddEditDiaryEntryView(profile: profile)
        }
        .sheet(isPresented: $showingExportSheet) {
            if let exportURL {
                ShareSheet(items: [exportURL])
            }
        }
        .confirmationDialog(
            L10n.string("profile.delete.confirm.title"),
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button(L10n.string("profile.delete.confirm.action"), role: .destructive) {
                deleteProfile()
            }
            Button(L10n.string("common.cancel"), role: .cancel) {}
        } message: {
            Text(L10n.string("profile.delete.confirm.message"))
        }
        .onAppear {
            if profile.milestones.isEmpty {
                MilestoneTemplateProvider.seedMilestones(for: profile, context: modelContext)
            }
        }
    }

    private var profileHeader: some View {
        ProfileHeaderCard(profile: profile)
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .diary:
            diaryTab
        case .growth:
            GrowthMetricsView(profile: profile)
        case .milestones:
            MilestonesView(profile: profile)
        }
    }

    private var diaryTab: some View {
        let accessibleEntries = PremiumAccess.accessibleEntries(
            from: profile.sortedEntries,
            isPremium: subscriptionManager.isPremium
        )
        let lockedEntryCount = PremiumAccess.lockedEntryCount(
            in: profile.sortedEntries,
            isPremium: subscriptionManager.isPremium
        )

        return Group {
            if profile.sortedEntries.isEmpty {
                EmptyStateView(
                    systemImage: "book.closed",
                    title: L10n.string("profile.diary.empty.title"),
                    message: L10n.string("profile.diary.empty.message")
                )
            } else if accessibleEntries.isEmpty {
                VStack(spacing: 20) {
                    DiaryHistoryLockedView {
                        subscriptionManager.showingPaywall = true
                    }
                }
                .padding()
            } else {
                List {
                    if lockedEntryCount > 0 {
                        DiaryHistoryUpgradeBanner(lockedEntryCount: lockedEntryCount) {
                            subscriptionManager.showingPaywall = true
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    }

                    ForEach(accessibleEntries) { entry in
                        NavigationLink {
                            DiaryEntryDetailView(entry: entry)
                        } label: {
                            DiaryEntryRowView(entry: entry)
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    }
                    .onDelete { offsets in
                        deleteEntries(at: offsets, in: accessibleEntries)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(L10n.string("common.add")) { showingAddEntry = true }
            }
        }
    }

    private func exportPDF() {
        guard subscriptionManager.requirePremium() else { return }
        if let url = ExportService.exportProfileDiaryPDF(profile: profile) {
            exportURL = url
            showingExportSheet = true
        }
    }

    private func deleteEntries(at offsets: IndexSet, in entries: [DiaryEntry]) {
        for index in offsets {
            let entry = entries[index]
            SpotlightIndexingService.removeEntry(entry)
            deletePhotos(for: entry)
            modelContext.delete(entry)
        }
    }

    private func deleteProfile() {
        SpotlightIndexingService.removeProfile(profile)
        for entry in profile.entries {
            SpotlightIndexingService.removeEntry(entry)
            deletePhotos(for: entry)
        }
        if let avatarPath = profile.avatarPhotoPath {
            PhotoStorageService.deleteImage(fileName: avatarPath)
        }
        modelContext.delete(profile)
    }

    private func deletePhotos(for entry: DiaryEntry) {
        for photo in entry.photos {
            PhotoStorageService.deleteImage(fileName: photo.fileName)
        }
    }
}

struct ProfileHeaderCard: View {
    @Environment(\.colorScheme) private var colorScheme
    let profile: Profile

    var body: some View {
        HStack(spacing: 16) {
            ProfileAvatarView(profile: profile, size: 76)

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text(profile.name)
                        .font(.title2.bold())
                    ProfileTypeBadge(type: profile.type)
                }

                Text(profile.ageDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 14) {
                    statPill("\(profile.entries.count)", label: L10n.string("common.diary"), icon: "book.fill")
                    statPill("\(profile.completedMilestoneCount)/\(profile.milestones.count)", label: L10n.string("common.milestone"), icon: "flag.fill")
                }
            }

            Spacer(minLength: 0)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .fill(AppTheme.headerGradient(for: profile.type))
        )
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .strokeBorder(
                    AppTheme.tint(for: profile.type).opacity(colorScheme == .dark ? 0.28 : 0.15),
                    lineWidth: 1
                )
        }
        .shadow(
            color: AppTheme.tint(for: profile.type).opacity(
                AppTheme.profileHeaderShadowOpacity(for: colorScheme)
            ),
            radius: 10,
            y: 4
        )
    }

    private func statPill(_ value: String, label: String, icon: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            Text(L10n.format("profile.stats.pill", value, label))
        }
        .font(.caption.weight(.medium))
        .foregroundStyle(AppTheme.tint(for: profile.type))
    }
}

struct DiaryEntryRowView: View {
    let entry: DiaryEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Spacer()
                Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if !entry.content.isEmpty {
                Text(entry.content)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            HStack(spacing: 8) {
                if !entry.photos.isEmpty {
                    Label(L10n.format("diary.row.photoCount", entry.photos.count), systemImage: "photo.on.rectangle.angled")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                ForEach(entry.tags) { tag in
                    TagChipView(tag: tag)
                }
            }
        }
        .cardStyle(padding: 14)
    }
}
