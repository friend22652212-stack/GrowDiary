import SwiftData
import SwiftUI

struct ProfileDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var profile: Profile

    @State private var showingEditProfile = false
    @State private var showingAddEntry = false
    @State private var showingDeleteConfirmation = false

    var body: some View {
        List {
            Section {
                HStack(spacing: 16) {
                    ProfileAvatarView(profile: profile, size: 72)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(profile.name)
                            .font(.title2.bold())
                        Text(profile.type.displayName)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(profile.ageDescription)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)

                if !profile.notes.isEmpty {
                    Text(profile.notes)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                if profile.sortedEntries.isEmpty {
                    EmptyStateView(
                        systemImage: "book.closed",
                        title: "還沒有日記",
                        message: "記錄第一次微笑、長牙、學會新把戲，或任何值得留念的時刻。"
                    )
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(profile.sortedEntries) { entry in
                        NavigationLink {
                            DiaryEntryDetailView(entry: entry)
                        } label: {
                            DiaryEntryRowView(entry: entry)
                        }
                    }
                    .onDelete(perform: deleteEntries)
                }
            } header: {
                HStack {
                    Text("成長日記")
                    Spacer()
                    Button("新增") { showingAddEntry = true }
                        .font(.subheadline)
                }
            }
        }
        .navigationTitle(profile.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("編輯檔案") { showingEditProfile = true }
                    Button("新增日記") { showingAddEntry = true }
                    Divider()
                    Button("刪除檔案", role: .destructive) {
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
        .confirmationDialog(
            "確定要刪除這個檔案嗎？",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("刪除檔案與所有日記", role: .destructive) {
                deleteProfile()
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("此動作無法復原，所有日記與照片都會被刪除。")
        }
    }

    private func deleteEntries(at offsets: IndexSet) {
        let entries = profile.sortedEntries
        for index in offsets {
            let entry = entries[index]
            deletePhotos(for: entry)
            modelContext.delete(entry)
        }
    }

    private func deleteProfile() {
        for entry in profile.entries {
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

struct DiaryEntryRowView: View {
    let entry: DiaryEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(entry.title)
                    .font(.headline)
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

            if !entry.photos.isEmpty {
                Label("\(entry.photos.count) 張照片", systemImage: "photo.on.rectangle.angled")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
