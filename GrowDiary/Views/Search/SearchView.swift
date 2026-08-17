import SwiftData
import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @Query(sort: \DiaryEntry.date, order: .reverse) private var allEntries: [DiaryEntry]
    @Query(sort: \DiaryTag.name) private var allTags: [DiaryTag]

    @State private var searchText = ""
    @State private var selectedTag: DiaryTag?

    private var accessibleEntries: [DiaryEntry] {
        PremiumAccess.accessibleEntries(from: allEntries, isPremium: subscriptionManager.isPremium)
    }

    private var lockedEntryCount: Int {
        PremiumAccess.lockedEntryCount(in: allEntries, isPremium: subscriptionManager.isPremium)
    }

    private var filteredEntries: [DiaryEntry] {
        accessibleEntries.filter { entry in
            let matchesSearch: Bool
            if searchText.isEmpty {
                matchesSearch = true
            } else {
                let query = searchText.lowercased()
                matchesSearch =
                    entry.title.lowercased().contains(query) ||
                    entry.content.lowercased().contains(query) ||
                    entry.profile?.name.lowercased().contains(query) == true ||
                    entry.tagNames.lowercased().contains(query)
            }

            let matchesTag = selectedTag == nil || entry.tags.contains(where: { $0.id == selectedTag?.id })
            return matchesSearch && matchesTag
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ScreenBackground()

                Group {
                    if filteredEntries.isEmpty {
                        if lockedEntryCount > 0, searchText.isEmpty, selectedTag == nil {
                            VStack(spacing: 20) {
                                DiaryHistoryLockedView {
                                    subscriptionManager.showingPaywall = true
                                }
                            }
                            .padding()
                        } else {
                            EmptyStateView(
                                systemImage: "magnifyingglass",
                                title: searchText.isEmpty ? L10n.string("search.empty.initial.title") : L10n.string("search.empty.noResults.title"),
                                message: searchText.isEmpty
                                    ? L10n.string("search.empty.initial.message")
                                    : L10n.string("search.empty.noResults.message")
                            )
                        }
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 14) {
                                DiaryHistoryUpgradeBanner(lockedEntryCount: lockedEntryCount) {
                                    subscriptionManager.showingPaywall = true
                                }

                                ForEach(filteredEntries) { entry in
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
            .navigationTitle(L10n.string("search.navigationTitle"))
            .searchable(text: $searchText, prompt: L10n.string("search.prompt"))
            .toolbar {
                if !allTags.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Button(L10n.string("search.tag.all")) { selectedTag = nil }
                            Divider()
                            ForEach(allTags) { tag in
                                Button(tag.name) { selectedTag = tag }
                            }
                        } label: {
                            Label(
                                selectedTag?.name ?? L10n.string("search.tag.filter"),
                                systemImage: "tag.fill"
                            )
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(AppTheme.babyPrimary, AppTheme.petPrimary)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SearchView()
        .modelContainer(for: [Profile.self, DiaryEntry.self, PhotoAttachment.self, DiaryTag.self], inMemory: true)
        .environmentObject(SubscriptionManager.shared)
}
