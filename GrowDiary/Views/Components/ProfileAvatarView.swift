import SwiftUI

struct ProfileAvatarView: View {
    let profile: Profile
    var size: CGFloat = 56

    var body: some View {
        Group {
            if let path = profile.avatarPhotoPath,
               let image = PhotoStorageService.loadImage(fileName: path) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    AppTheme.softBackground(for: profile.type),
                                    AppTheme.tint(for: profile.type).opacity(0.25),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Image(systemName: profile.type.systemImage)
                        .font(.system(size: size * 0.38, weight: .semibold))
                        .foregroundStyle(AppTheme.tint(for: profile.type))
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay {
            Circle()
                .strokeBorder(AppTheme.tint(for: profile.type).opacity(0.35), lineWidth: 2)
        }
        .shadow(color: AppTheme.tint(for: profile.type).opacity(0.18), radius: 6, y: 3)
    }
}
