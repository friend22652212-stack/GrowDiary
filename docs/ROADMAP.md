# GrowDiary 開發路線圖

## 第一階段 — 核心 MVP ✅

- [x] 專案架構（SwiftUI + SwiftData）
- [x] 寶寶／寵物檔案 CRUD
- [x] 日記 CRUD（文字 + 多張照片）
- [x] 時間軸總覽
- [x] 本機照片儲存
- [x] App 圖示設計

## 第二階段 — 成長數據 ✅

- [x] 身高／體重／頭圍紀錄（寶寶）
- [x] 體重紀錄（寵物）
- [x] 成長曲線圖表
- [x] 里程碑模板（第一次微笑、長牙、學走路等）
- [x] 自訂里程碑

## 第三階段 — 進階功能 ✅（核心）

- [x] 搜尋與標籤
- [x] 日記 PDF 匯出
- [x] iCloud / CloudKit 同步（多裝置）
- [x] 桌面 Widget（最新照片或年齡）
- [x] 深色模式優化
- [x] 多語系（繁中、英文、韓文）

## 第四階段 — 上架準備 ⏳

- [x] 基本 UI 視覺打磨
- [x] Premium 訂閱（StoreKit 2，NT$ 690／年，7 天試用）— 見 [PREMIUM.md](PREMIUM.md)
- [x] 隱私權政策草稿 + GitHub Pages 設定（見 [docs/privacy/README.md](privacy/README.md)）— 待建立 GitHub repo 並推送
- [ ] App Store 截圖與宣傳文案
- [ ] TestFlight 封測
- [ ] App Store 審核提交

## 第五階段 A — 基礎設施 ✅

- [x] 備份與還原（`.growdiary` 壓縮包）
- [x] 提醒通知（日記、量體重）
- [x] Face ID / App 鎖定
- [x] Spotlight 搜尋

## 第五～七階段 — 其餘進階功能 📋

你已選定後續功能（分享卡、Live Activity、疫苗紀錄、WHO 曲線、月曆、回顧、影片、語音、家庭共享、AI 摘要等；**不含印刷相簿分潤**）。

**完整分階段計畫見 [FEATURE_ROADMAP.md](FEATURE_ROADMAP.md)**

| 版本 | 重點 |
|------|------|
| 1.0 | 上架（現有功能） |
| 1.1 | 備份、通知、Face ID、Spotlight |
| 1.2 | 分享卡、月曆、疫苗、WHO、回顧 |
| 1.3 | Siri、Live Activity |
| 1.4 | 影片、語音 |
| 2.0 | 家庭共享、多使用者權限 |
| 2.1 | AI 摘要 |

## 專案路徑

```
/Users/kao/Desktop/GrowDiary/
```

## 架構文件

詳見 [ARCHITECTURE.md](ARCHITECTURE.md)
