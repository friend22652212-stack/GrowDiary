import SwiftData
import SwiftUI

struct DiaryEntryDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Bindable var entry: DiaryEntry

    @State private var showingEditEntry = false
    @State private var selectedPhoto: PhotoAttachment?
    @State private var showingDeleteConfirmation = false

    var body: some View {
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

                if !entry.sortedPhotos.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("照片")
                            .font(.headline)
                        PhotoGridView(photos: entry.sortedPhotos) { photo in
                            selectedPhoto = photo
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("日記詳情")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("編輯") { showingEditEntry = true }
                    Button("刪除", role: .destructive) {
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
            "確定要刪除這則日記嗎？",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("刪除", role: .destructive) {
                deleteEntry()
                dismiss()
            }
            Button("取消", role: .cancel) {}
        }
    }

    private func deleteEntry() {
        for photo in entry.photos {
            PhotoStorageService.deleteImage(fileName: photo.fileName)
        }
        modelContext.delete(entry)
    }
}

extension PhotoAttachment: @retroactive Identifiable {}
