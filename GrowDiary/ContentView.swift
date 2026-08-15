import SwiftData
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ProfilesListView()
                .tabItem {
                    Label("檔案", systemImage: "person.2.fill")
                }

            TimelineView()
                .tabItem {
                    Label("時間軸", systemImage: "clock.fill")
                }

            SettingsView()
                .tabItem {
                    Label("設定", systemImage: "gearshape.fill")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Profile.self, DiaryEntry.self, PhotoAttachment.self], inMemory: true)
}
