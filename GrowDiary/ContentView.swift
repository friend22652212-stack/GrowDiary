import CoreSpotlight
import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @ObservedObject private var appLockManager = AppLockManager.shared
    @ObservedObject private var spotlightNavigation = SpotlightNavigationState.shared

    @Query(sort: \Profile.name) private var profiles: [Profile]
    @Query(sort: \DiaryEntry.date, order: .reverse) private var entries: [DiaryEntry]

    @State private var selectedTab: AppTab = .profiles
    @State private var spotlightEntry: DiaryEntry?
    @State private var spotlightProfile: Profile?

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                ProfilesListView()
                    .tabItem {
                        Label(L10n.string("tab.profiles"), systemImage: "person.2.fill")
                    }
                    .tag(AppTab.profiles)

                TimelineView()
                    .tabItem {
                        Label(L10n.string("tab.timeline"), systemImage: "clock.fill")
                    }
                    .tag(AppTab.timeline)

                SearchView()
                    .tabItem {
                        Label(L10n.string("tab.search"), systemImage: "magnifyingglass")
                    }
                    .tag(AppTab.search)

                SettingsView(selectedTab: $selectedTab)
                    .tabItem {
                        Label(L10n.string("tab.settings"), systemImage: "gearshape.fill")
                    }
                    .tag(AppTab.settings)
            }

            if appLockManager.isLocked {
                AppLockOverlay()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: appLockManager.isLocked)
        .onAppear {
            refreshWidgetSnapshots()
            reindexSpotlight()
            Task { await subscriptionManager.refreshEntitlements() }
            if AppSettings.isAppLockEnabled, subscriptionManager.isPremium {
                appLockManager.lockIfNeeded()
                Task { await appLockManager.authenticate() }
            }
        }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .active:
                refreshWidgetSnapshots()
                Task { await subscriptionManager.refreshEntitlements() }
                appLockManager.unlockIfDisabled()
                if appLockManager.isLocked {
                    Task { await appLockManager.authenticate() }
                }
            case .background:
                if subscriptionManager.isPremium {
                    appLockManager.lockIfNeeded()
                }
            case .inactive:
                break
            @unknown default:
                break
            }
        }
        .onChange(of: profiles.count) { _, _ in
            refreshWidgetSnapshots()
            reindexSpotlight()
        }
        .onChange(of: entries.count) { _, _ in
            reindexSpotlight()
        }
        .onChange(of: languageManager.current) { _, _ in
            refreshWidgetSnapshots()
        }
        .onChange(of: spotlightNavigation.pendingEntryID) { _, entryID in
            guard let entryID,
                  let entry = entries.first(where: { $0.id == entryID }) else { return }
            spotlightEntry = entry
            selectedTab = .timeline
            spotlightNavigation.clearPendingEntry()
        }
        .onChange(of: spotlightNavigation.pendingProfileID) { _, profileID in
            guard let profileID,
                  let profile = profiles.first(where: { $0.id == profileID }) else { return }
            spotlightProfile = profile
            selectedTab = .profiles
            spotlightNavigation.clearPendingProfile()
        }
        .onContinueUserActivity(CSSearchableItemActionType) { activity in
            _ = SpotlightIndexingService.handle(userActivity: activity)
        }
        .sheet(isPresented: $subscriptionManager.showingPaywall) {
            PaywallView()
        }
        .sheet(item: $spotlightEntry) { entry in
            NavigationStack {
                DiaryEntryDetailView(entry: entry)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button(L10n.string("common.close")) {
                                spotlightEntry = nil
                            }
                        }
                    }
            }
        }
        .sheet(item: $spotlightProfile) { profile in
            NavigationStack {
                ProfileDetailView(profile: profile)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button(L10n.string("common.close")) {
                                spotlightProfile = nil
                            }
                        }
                    }
            }
        }
    }

    private func refreshWidgetSnapshots() {
        WidgetSnapshotService.refreshSnapshots(for: profiles)
    }

    private func reindexSpotlight() {
        SpotlightIndexingService.indexAll(profiles: profiles, entries: entries)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [
            Profile.self,
            DiaryEntry.self,
            PhotoAttachment.self,
            GrowthMetric.self,
            Milestone.self,
            DiaryTag.self,
        ], inMemory: true)
        .environmentObject(LanguageManager.shared)
        .environmentObject(SubscriptionManager.shared)
}
