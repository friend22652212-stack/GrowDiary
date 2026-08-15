import SwiftData
import SwiftUI

@main
struct GrowDiaryApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            Profile.self,
            DiaryEntry.self,
            PhotoAttachment.self,
        ])
    }
}
