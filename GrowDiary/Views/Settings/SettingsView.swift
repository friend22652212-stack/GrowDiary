import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("關於 Grow Diary") {
                    LabeledContent("版本", value: "1.0.0 (MVP)")
                    LabeledContent("開發階段", value: "第一階段")
                }

                Section("隱私") {
                    Text("所有日記與照片目前儲存在您的裝置本機，不會上傳到雲端。")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Section("即將推出") {
                    Label("iCloud 同步", systemImage: "icloud")
                    Label("成長里程碑", systemImage: "flag.fill")
                    Label("身高體重紀錄", systemImage: "chart.line.uptrend.xyaxis")
                    Label("PDF 匯出", systemImage: "doc.richtext")
                }
            }
            .navigationTitle("設定")
        }
    }
}

#Preview {
    SettingsView()
}
