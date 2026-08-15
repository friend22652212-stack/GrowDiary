import SwiftData
import SwiftUI

struct TimelineView: View {
    @Query(sort: \DiaryEntry.date, order: .reverse) private var entries: [DiaryEntry]

    var body: some View {
        NavigationStack {
            Group {
                if entries.isEmpty {
                    EmptyStateView(
                        systemImage: "clock",
                        title: "時間軸還是空的",
                        message: "所有寶寶與寵物的日記會依時間排序顯示在這裡。"
                    )
                } else {
                    List(entries) { entry in
                        NavigationLink {
                            DiaryEntryDetailView(entry: entry)
                        } label: {
                            TimelineRowView(entry: entry)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("時間軸")
        }
    }
}

struct TimelineRowView: View {
    let entry: DiaryEntry

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if let profile = entry.profile {
                ProfileAvatarView(profile: profile, size: 40)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(entry.title)
                        .font(.headline)
                    Spacer()
                    Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let profile = entry.profile {
                    Text(profile.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if !entry.content.isEmpty {
                    Text(entry.content)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                if let firstPhoto = entry.sortedPhotos.first,
                   let image = PhotoStorageService.loadImage(fileName: firstPhoto.fileName) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 72, height: 72)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    TimelineView()
        .modelContainer(for: [Profile.self, DiaryEntry.self, PhotoAttachment.self], inMemory: true)
}
