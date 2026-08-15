# Grow Diary（成長日記）

記錄寶寶與寵物成長歷程的 iOS 日記 App，支援文字、照片、多檔案管理與時間軸瀏覽。

- **App 名稱**：Grow Diary
- **Bundle ID**：`com.kao.growdiary`

## 功能（第一階段 MVP）

- 建立寶寶或寵物檔案（名稱、出生／到家日期、大頭照、備註）
- 撰寫成長日記（標題、內容、日期、多張照片）
- 依檔案瀏覽日記，或以時間軸查看所有紀錄
- 本機儲存（SwiftData + 檔案系統照片）

## 開啟專案

1. 用 Xcode 開啟 `GrowDiary.xcodeproj`
2. 在 **Signing & Capabilities** 設定您的 **Team**（Apple Developer 帳號）
3. 確認 **Bundle Identifier** 為 `com.kao.growdiary`
4. 選擇模擬器或實機，按 Run

## 技術棧

- Swift 6 / SwiftUI
- SwiftData（資料持久化）
- PhotosUI（相簿選圖）

## 專案結構

```
GrowDiary/
├── GrowDiaryApp.swift          # App 入口
├── ContentView.swift           # Tab 導覽
├── Models/                     # 資料模型
├── Services/                   # 照片儲存等服務
├── Views/                      # 畫面
├── Theme/                      # 主題色彩
└── Assets.xcassets/            # 圖示與色彩
```

## 後續階段

詳見 [docs/ROADMAP.md](docs/ROADMAP.md) 與 [docs/APP_STORE_CHECKLIST.md](docs/APP_STORE_CHECKLIST.md)。

## 授權

Private — 待您決定授權方式。
