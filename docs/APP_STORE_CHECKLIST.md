# App Store 上架檢查清單

您已有 Apple Developer 帳號，以下是從現在到正式上架的步驟。

## 一、開發者後台設定

1. 登入 [App Store Connect](https://appstoreconnect.apple.com)
2. **我的 App** → **+** → **新增 App**
   - 平台：iOS
   - 名稱：Grow Diary
   - 主要語言：繁體中文
   - Bundle ID：在 [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/identifiers/list) 建立，需與 Xcode 專案一致
   - SKU：自訂唯一識別碼（例如 `growdiary-001`）

## 二、Xcode 專案設定

- [ ] 設定 **Signing Team**（您的 Developer 帳號）
- [ ] 修改 **Bundle Identifier** 為您註冊的 ID
- [ ] 確認 **Version**（1.0.0）與 **Build**（1）
- [ ] 加入 **App Icon**（1024×1024，無透明、無圓角）
- [ ] 確認相簿／相機權限描述文字（已內建於專案）

## 三、App Store 必填素材

| 項目 | 說明 |
|------|------|
| App 名稱 | 最多 30 字元 |
| 副標題 | 簡短描述（例如：記錄寶寶與寵物的每一天） |
| 描述 | 完整功能介紹（繁體中文） |
| 關鍵字 | 逗號分隔，例如：成長,日記,寶寶,寵物,親子 |
| 支援 URL | 可先用 GitHub Pages 或 Notion 公開頁 |
| 隱私權政策 URL | **必填**，即使資料只存本機也建議提供 |
| 截圖 | iPhone 6.7"、6.5"、5.5" 等必要尺寸（依 Apple 當前要求） |
| 年齡分級 | 問卷填寫，通常為 4+ |

## 四、隱私與審核

- **App 隱私問卷**：若資料僅存本機、不上傳，可申報「不收集資料」或「資料不離開裝置」
- **照片權限**：已設定 `NSPhotoLibraryUsageDescription`
- **Guideline 4.0**：介面需完整、不可有明顯 placeholder
- **Guideline 2.1**：需有可用的核心功能（目前 MVP 已具備）

## 五、建置與提交

1. Xcode：**Product → Archive**
2. **Organizer** → **Distribute App** → **App Store Connect**
3. 在 App Store Connect 選擇剛上傳的 Build
4. 填完所有必填欄位 → **提交審核**

## 六、TestFlight（建議先做）

正式送審前，建議先：

1. Archive 上傳至 App Store Connect
2. 在 **TestFlight** 邀請自己或親友測試
3. 確認照片、日記、刪除等功能正常
4. 收集回饋後再送審

## 七、常見拒審原因與預防

| 原因 | 預防方式 |
|------|----------|
| 缺少隱私權政策 | 建立簡單網頁說明本機儲存、不收集個資 |
| 功能不完整 | 確保無空白頁、無「即將推出」按鈕可點卻無功能 |
| 截圖與實際不符 | 用真實 App 畫面截圖 |
| 崩潰或閃退 | TestFlight 多裝置測試 |

## 八、Bundle ID 建議

目前 Bundle ID：`com.kao.growdiary`

需在 [Apple Developer](https://developer.apple.com/account/resources/identifiers/list) 註冊此 Identifier，並與 Xcode 專案一致。

---

完成第一階段 UI 打磨與 App 圖示後，即可進入 TestFlight。需要協助任一階段（圖示、隱私權頁、第二階段功能）可再告訴我。
