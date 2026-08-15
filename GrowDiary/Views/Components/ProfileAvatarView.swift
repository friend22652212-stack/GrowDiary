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
                        .fill(AppTheme.tint(for: profile.type).opacity(0.35))
                    Image(systemName: profile.type.systemImage)
                        .font(.system(size: size * 0.38))
                        .foregroundStyle(AppTheme.tint(for: profile.type))
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}
