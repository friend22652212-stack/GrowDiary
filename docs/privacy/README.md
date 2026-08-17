# 隱私權政策 — GitHub Pages 上架說明

## 檔案

| 檔案 | 語言 | 公開 URL（部署後） |
|------|------|-------------------|
| [zh-Hant.md](zh-Hant.md) | 繁體中文 | `https://friend22652212-stack.github.io/GrowDiary/privacy/zh-Hant.html` |
| [en.md](en.md) | English | `https://friend22652212-stack.github.io/GrowDiary/privacy/en.html` |
| [ko.md](ko.md) | 한국어 | `https://friend22652212-stack.github.io/GrowDiary/privacy/ko.html` |

首頁：`https://friend22652212-stack.github.io/GrowDiary/`

## 一次性設定步驟

### 1. 在 GitHub 建立 Repository

1. 前往 [github.com/new](https://github.com/new)
2. Repository 名稱：`GrowDiary`（或你喜歡的名稱，URL 會跟著名稱變）
3. 選 **Public**
4. **不要**勾選 README（本地已有專案）
5. 建立後複製 repo URL，例如 `https://github.com/你的帳號/GrowDiary.git`

### 2. 推送程式碼

在終端機於專案根目錄執行：

```bash
cd /Users/kao/Desktop/GrowDiary

# 若尚未設定 remote（只需做一次）
git remote add origin https://github.com/你的帳號/GrowDiary.git

# 加入 Pages 相關檔案並推送
git add docs/_config.yml docs/index.md docs/privacy/
git commit -m "Add privacy policy pages for GitHub Pages"
git push -u origin main
```

> 若 `git remote add` 提示已存在，改用 `git remote set-url origin ...` 更新網址。

### 3. 啟用 GitHub Pages

1. 開啟 repo → **Settings** → **Pages**
2. **Build and deployment** → Source：**Deploy from a branch**
3. Branch：`main`，資料夾：**/docs**
4. 儲存後等待 1～3 分鐘

部署成功後會顯示：`Your site is live at https://你的帳號.github.io/GrowDiary/`

### 4. App Store Connect

- **Privacy Policy URL**（台灣區建議）：  
  `https://你的帳號.github.io/GrowDiary/privacy/zh-Hant.html`

## 已完成的設定

- [x] 聯絡 Email：`friend22652212@yahoo.com.tw`
- [x] Jekyll 設定（`docs/_config.yml`）— 使用 Cayman 主題
- [x] 首頁（`docs/index.md`）— 三語政策連結
- [x] 排除內部文件（ROADMAP、PREMIUM 等不會被發布）

## App Store 隱私問卷建議勾選

| 資料類型 | 是否收集 | 說明 |
|----------|----------|------|
| 聯絡資訊 | 否 | 無註冊 |
| 使用者內容 | 是（不連結身分） | 日記、照片存本機／使用者 iCloud |
| 識別碼 | 否 | 無廣告 ID |
| 購買紀錄 | 是 | 由 Apple 處理訂閱 |
| 使用資料 | 否 | 無分析 SDK |

## 更新政策

修改 `docs/privacy/*.md` 後：

```bash
git add docs/privacy/
git commit -m "Update privacy policy"
git push
```

GitHub Pages 會在數分鐘內自動重新部署。
