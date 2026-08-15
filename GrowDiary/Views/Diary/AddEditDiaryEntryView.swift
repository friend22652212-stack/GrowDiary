import PhotosUI
import SwiftData
import SwiftUI

struct AddEditDiaryEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var profile: Profile
    var entry: DiaryEntry?

    @State private var title = ""
    @State private var content = ""
    @State private var date = Date()
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var pendingImages: [UIImage] = []
    @State private var errorMessage: String?

    private var isEditing: Bool { entry != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("日記內容") {
                    TextField("標題", text: $title)
                    DatePicker("日期", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    TextField("今天發生了什麼？", text: $content, axis: .vertical)
                        .lineLimit(4...10)
                }

                Section("照片") {
                    PhotosPicker(
                        selection: $selectedPhotos,
                        maxSelectionCount: 12,
                        matching: .images
                    ) {
                        Label("加入照片", systemImage: "photo.badge.plus")
                    }

                    if !pendingImages.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(Array(pendingImages.enumerated()), id: \.offset) { index, image in
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 88, height: 88)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))

                                        Button {
                                            pendingImages.remove(at: index)
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundStyle(.white, .black.opacity(0.6))
                                        }
                                        .offset(x: 6, y: -6)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "編輯日記" : "新增日記")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("儲存") { save() }
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear(perform: loadExistingEntry)
            .onChange(of: selectedPhotos) { _, newItems in
                Task { await loadSelectedPhotos(from: newItems) }
            }
            .alert("發生錯誤", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("好") {}
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    private func loadExistingEntry() {
        guard let entry else { return }
        title = entry.title
        content = entry.content
        date = entry.date

        pendingImages = entry.sortedPhotos.compactMap {
            PhotoStorageService.loadImage(fileName: $0.fileName)
        }
    }

    private func loadSelectedPhotos(from items: [PhotosPickerItem]) async {
        var images: [UIImage] = []

        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                images.append(image)
            }
        }

        await MainActor.run {
            pendingImages = images
        }
    }

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        do {
            let targetEntry: DiaryEntry

            if let entry {
                targetEntry = entry
                targetEntry.title = trimmedTitle
                targetEntry.content = content
                targetEntry.date = date

                for photo in entry.photos {
                    PhotoStorageService.deleteImage(fileName: photo.fileName)
                }
                entry.photos.removeAll()
            } else {
                let newEntry = DiaryEntry(title: trimmedTitle, content: content, date: date, profile: profile)
                modelContext.insert(newEntry)
                profile.entries.append(newEntry)
                targetEntry = newEntry
            }

            for (index, image) in pendingImages.enumerated() {
                let fileName = try PhotoStorageService.saveImage(image)
                let attachment = PhotoAttachment(fileName: fileName, sortOrder: index)
                attachment.entry = targetEntry
                targetEntry.photos.append(attachment)
            }

            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
