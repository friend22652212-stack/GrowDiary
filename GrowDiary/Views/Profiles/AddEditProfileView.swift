import PhotosUI
import SwiftData
import SwiftUI

struct AddEditProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var profile: Profile?

    @State private var name = ""
    @State private var type: ProfileType = .baby
    @State private var birthDate = Date()
    @State private var notes = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var avatarImage: UIImage?
    @State private var errorMessage: String?

    private var isEditing: Bool { profile != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(L10n.string("profile.field.name"), text: $name)

                    Picker(L10n.string("common.type"), selection: $type) {
                        ForEach(ProfileType.allCases) { profileType in
                            Label(profileType.displayName, systemImage: profileType.systemImage)
                                .tag(profileType)
                        }
                    }

                    DatePicker(L10n.string("profile.field.birthDate"), selection: $birthDate, displayedComponents: .date)
                } header: {
                    Text(L10n.string("profile.form.section.basic"))
                }

                Section {
                    HStack {
                        avatarPreview
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            Label(L10n.string("profile.action.choosePhoto"), systemImage: "photo.on.rectangle")
                        }
                    }
                } header: {
                    Text(L10n.string("profile.form.section.avatar"))
                }

                Section {
                    TextField(L10n.string("profile.field.notesPlaceholder"), text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text(L10n.string("common.notes"))
                }
            }
            .navigationTitle(L10n.string(isEditing ? "profile.title.edit" : "profile.title.add"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.string("common.cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.string("common.save")) { save() }
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear(perform: loadExistingProfile)
            .onChange(of: selectedPhoto) { _, newValue in
                Task { await loadSelectedPhoto(from: newValue) }
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

    @ViewBuilder
    private var avatarPreview: some View {
        Group {
            if let avatarImage {
                Image(uiImage: avatarImage)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    Circle().fill(AppTheme.tint(for: type).opacity(0.35))
                    Image(systemName: type.systemImage)
                        .foregroundStyle(AppTheme.tint(for: type))
                }
            }
        }
        .frame(width: 64, height: 64)
        .clipShape(Circle())
    }

    private func loadExistingProfile() {
        guard let profile else { return }
        name = profile.name
        type = profile.type
        birthDate = profile.birthDate
        notes = profile.notes
        if let path = profile.avatarPhotoPath {
            avatarImage = PhotoStorageService.loadImage(fileName: path)
        }
    }

    private func loadSelectedPhoto(from item: PhotosPickerItem?) async {
        guard let item,
              let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else { return }
        await MainActor.run { avatarImage = image }
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        do {
            var avatarPath: String?

            if let avatarImage {
                avatarPath = try PhotoStorageService.saveImage(avatarImage)

                if let oldPath = profile?.avatarPhotoPath, oldPath != avatarPath {
                    PhotoStorageService.deleteImage(fileName: oldPath)
                }
            }

            if let profile {
                profile.name = trimmedName
                profile.type = type
                profile.birthDate = birthDate
                profile.notes = notes
                if let avatarPath {
                    profile.avatarPhotoPath = avatarPath
                }
                SpotlightIndexingService.indexProfile(profile)
            } else {
                let newProfile = Profile(
                    name: trimmedName,
                    type: type,
                    birthDate: birthDate,
                    notes: notes,
                    avatarPhotoPath: avatarPath
                )
                modelContext.insert(newProfile)
                SpotlightIndexingService.indexProfile(newProfile)
            }

            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
