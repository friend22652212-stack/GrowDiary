# Grow Diary Premium 功能對照表

> **定價：** 年訂 **NT$ 690**／年，或月訂 **NT$ 90**／月  
> **試用：** **7 天免費**，試用期內 Premium **全功能開放**  
> **v1.0** 起接入 StoreKit 2

Product ID：
- 年訂 `com.kao.growdiary.premium.yearly`
- 月訂 `com.kao.growdiary.premium.monthly`

---

## 免費版 vs Premium

| 功能 | 免費版 | Premium |
|------|:------:|:-------:|
| 成長檔案 | 1 個 | 無限 |
| 日記（文字＋照片） | 最近 **30 天** | 無限制 |
| 時間軸 | ✅ | ✅ |
| App 內搜尋與標籤 | ✅ | ✅ |
| 成長數據（身高／體重／頭圍） | ✅ | ✅ |
| 里程碑 | ✅ | ✅ |
| 桌面 Widget（基本） | ✅ | ✅ |
| 本機照片儲存 | ✅ | ✅ |
| 提醒通知（日記、量體重） | ✅ | ✅ |
| 多語系（繁中／英／韓） | ✅ | ✅ |
| **iCloud 多裝置同步** | ❌ | ✅ |
| **備份與還原** | ❌ | ✅ |
| **PDF 匯出** | ❌ | ✅ |
| **Face ID / App 鎖定** | ❌ | ✅ |
| **Spotlight 系統搜尋** | ❌ | ✅ |
| 分享卡片（5B 上線後） | ❌ | ✅ |
| 月曆檢視（5B） | ❌ | ✅ |
| 疫苗／驅蟲紀錄（5B） | ❌ | ✅ |
| WHO 生長曲線（5B） | ❌ | ✅ |
| 家庭共享（2.0） | ❌ | ✅ |
| AI 摘要（2.1） | ❌ | ✅ |

---

## 付費牆觸發點（v1.0）

| 觸發時機 | 行為 |
|----------|------|
| 新增第 2 個檔案 | 顯示 Paywall |
| 查看 30 天以前的日記 | 顯示 Paywall |
| 新增／編輯 30 天以前的日記日期 | 顯示 Paywall |
| 開啟 iCloud 同步 | 顯示 Paywall |
| 匯出／還原備份 | 顯示 Paywall |
| 匯出 PDF | 顯示 Paywall |
| 開啟 App 鎖定 | 顯示 Paywall |
| 開啟 Spotlight 索引 | 顯示 Paywall |
| 設定 → 升級 Premium | 顯示 Paywall |

---

## 試用期規則

1. 試用期 **7 天**，Premium **全功能**開放。
2. 試用結束 **未訂閱** → 降回免費版；**資料保留**。
3. 已建立的第 2 個以上檔案 **仍可查看**，但 **無法新增** 新檔案。
4. 超過 30 天的日記 **仍保留**，但免費版 **無法查看**；升級 Premium 即可解鎖。
5. 試用結束後自動關閉：iCloud、App 鎖、Spotlight（若曾開啟）。
6. 試用結束 **有訂閱** → 維持 Premium。

---

## App Store Connect 設定清單

- [ ] 建立訂閱群組「Premium」
- [ ] 新增年訂 `com.kao.growdiary.premium.yearly`（NT$ 690／年）
- [ ] 新增月訂 `com.kao.growdiary.premium.monthly`（NT$ 90／月）
- [ ] 介紹性優惠：**7 天免費試用**（兩方案皆設）
- [ ] 支援 Apple 家庭共享（Family Sharing）

---

## 本地測試

Xcode 使用 `GrowDiary.storekit` 設定檔（Scheme → Run → StoreKit Configuration）。
