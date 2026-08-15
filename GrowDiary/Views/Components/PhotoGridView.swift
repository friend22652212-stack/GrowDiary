import SwiftUI

struct PhotoGridView: View {
    let photos: [PhotoAttachment]
    var onTap: ((PhotoAttachment) -> Void)?

    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(photos, id: \.id) { photo in
                Button {
                    onTap?(photo)
                } label: {
                    photoCell(for: photo)
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private func photoCell(for photo: PhotoAttachment) -> some View {
        if let image = PhotoStorageService.loadImage(fileName: photo.fileName) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(height: 110)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.secondary.opacity(0.15))
                .frame(height: 110)
                .overlay {
                    Image(systemName: "photo")
                        .foregroundStyle(.secondary)
                }
        }
    }
}

struct PhotoViewerSheet: View {
    let photo: PhotoAttachment
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if let image = PhotoStorageService.loadImage(fileName: photo.fileName) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black)
                } else {
                    EmptyStateView(
                        systemImage: "photo",
                        title: "找不到照片",
                        message: "這張照片可能已被移除。"
                    )
                }
            }
            .navigationTitle(photo.caption.isEmpty ? "照片" : photo.caption)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }
}
