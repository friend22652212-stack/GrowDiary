import SwiftData
import SwiftUI

struct DiaryEntryDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var subscriptionManager: SubscriptionManager

    @Bindable var entry: DiaryEntry

    @State private var showingEditEntry = false
    @State private var selectedPhoto: PhotoAttachment?
    @State private var showingDeleteConfirmation = false

    private var isAccessible: Bool {
        PremiumAccess.isDiaryEntryAccessible(entry, isPremium: subscriptionManager.isPremium)
    }

    var body: some View {
        Group {
            if isAccessible {
                entryContent
            } else {
                DiaryHistoryLockedView {
                    subscriptionManager.showingPaywall = true
                }
                .navigationTitle(entry.title)
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }

    private var entryContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(entry.title)
                        .font(.title.bold())

                    HStack {
                        if let profile = entry.profile {
                            Label(profile.name, systemImage: profile.type.systemImage)
                        }
                        Spacer()
                        Text(entry.date.formatted(date: .long, time: .shortened))
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }

                if !entry.content.isEmpty {
                    Text(entry.content)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if !entry.tags.isEmpty {
                    HStack(spacing: 8) {
                        ForEach(entry.tags) { tag in
                            TagChipView(tag: tag)
                        }
                    }
                }

                if !entry.photos.isEmpty {
                    PhotoGridView(photos: entry.sortedPhotos) { photo in
                        selectedPhoto = photo
                    }
                }
            }
            .padding()
        }
        .navigationTitle(entry.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(L10n.string("common.edit")) { showingEditEntry = true }
                    Button(L10n.string("common.delete"), role: .destructive) {
                        showingDeleteConfirmation = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEditEntry) {
            if let profile = entry.profile {
                AddEditDiaryEntryView(profile: profile, entry: entry)
            }
        }
        .sheet(item: $selectedPhoto) { photo in
            PhotoViewerSheet(photo: photo)
        }
        .confirmationDialog(
            L10n.string("diary.delete.confirm.title"),
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button(L10n.string("common.delete"), role: .destructive) {
                deleteEntry()
                dismiss()
            }
            Button(L10n.string("common.cancel"), role: .cancel) {}
        }
    }

    private func deleteEntry() {
        SpotlightIndexingService.removeEntry(entry)
        for photo in entry.photos {
            PhotoStorageService.deleteImage(fileName: photo.fileName)
        }
        modelContext.delete(entry)
    }
}

extension PhotoAttachment: Identifiable {}
