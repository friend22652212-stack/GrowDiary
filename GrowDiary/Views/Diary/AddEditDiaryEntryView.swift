import PhotosUI
import SwiftData
import SwiftUI

struct AddEditDiaryEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var subscriptionManager: SubscriptionManager

    var profile: Profile
    var entry: DiaryEntry?

    @State private var title = ""
    @State private var content = ""
    @State private var date = Date()
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var pendingImages: [UIImage] = []
    @State private var selectedTags: [DiaryTag] = []
    @State private var errorMessage: String?

    private var isEditing: Bool { entry != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(L10n.string("common.title"), text: $title)
                    DatePicker(L10n.string("common.date"), selection: $date, displayedComponents: [.date, .hourAndMinute])
                    TextField(L10n.string("diary.field.contentPlaceholder"), text: $content, axis: .vertical)
                        .lineLimit(4...10)
                } header: {
                    Text(L10n.string("diary.form.section.content"))
                }

                TagPickerSection(selectedTags: $selectedTags)

                Section {
                    PhotosPicker(
                        selection: $selectedPhotos,
                        maxSelectionCount: 12,
                        matching: .images
                    ) {
                        Label(L10n.string("diary.action.addPhotos"), systemImage: "photo.badge.plus")
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
                } header: {
                    Text(L10n.string("common.photos"))
                }
            }
            .navigationTitle(L10n.string(isEditing ? "diary.title.edit" : "diary.title.add"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.string("common.cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.string("common.save")) { save() }
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear(perform: loadExistingEntry)
            .onChange(of: selectedPhotos) { _, newItems in
                Task { await loadSelectedPhotos(from: newItems) }
            }
            .alert(L10n.string("common.error.title"), isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button(L10n.string("common.ok")) {}
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
        selectedTags = entry.tags
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

        guard PremiumAccess.isDiaryDateAccessible(date, isPremium: subscriptionManager.isPremium) else {
            subscriptionManager.showingPaywall = true
            return
        }

        do {
            let targetEntry: DiaryEntry

            if let entry {
                targetEntry = entry
                targetEntry.title = trimmedTitle
                targetEntry.content = content
                targetEntry.date = date
                targetEntry.tags = selectedTags

                for photo in entry.photos {
                    PhotoStorageService.deleteImage(fileName: photo.fileName)
                }
                entry.photos.removeAll()
            } else {
                let newEntry = DiaryEntry(title: trimmedTitle, content: content, date: date, profile: profile)
                newEntry.tags = selectedTags
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

            SpotlightIndexingService.indexEntry(targetEntry)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
