import PhotosUI
import SwiftData
import SwiftUI

struct ProfilesListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Profile.createdAt, order: .reverse) private var profiles: [Profile]

    @State private var showingAddProfile = false

    var body: some View {
        NavigationStack {
            Group {
                if profiles.isEmpty {
                    EmptyStateView(
                        systemImage: "person.crop.circle.badge.plus",
                        title: "還沒有檔案",
                        message: "建立第一個寶寶或寵物檔案，開始記錄成長日記。"
                    )
                } else {
                    List(profiles) { profile in
                        NavigationLink(value: profile) {
                            ProfileRowView(profile: profile)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("成長檔案")
            .navigationDestination(for: Profile.self) { profile in
                ProfileDetailView(profile: profile)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddProfile = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("新增檔案")
                }
            }
            .sheet(isPresented: $showingAddProfile) {
                AddEditProfileView()
            }
        }
    }
}

struct ProfileRowView: View {
    let profile: Profile

    var body: some View {
        HStack(spacing: 14) {
            ProfileAvatarView(profile: profile)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(profile.name)
                        .font(.headline)
                    Text(profile.type.displayName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(AppTheme.tint(for: profile.type).opacity(0.35))
                        .clipShape(Capsule())
                }

                Text(profile.ageDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("\(profile.entries.count) 則日記")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ProfilesListView()
        .modelContainer(for: [Profile.self, DiaryEntry.self, PhotoAttachment.self], inMemory: true)
}
