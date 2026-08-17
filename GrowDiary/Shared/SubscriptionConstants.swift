import Foundation

enum SubscriptionConstants {
    /// App Store Connect 自動續訂年訂產品 ID
    static let annualProductID = "com.kao.growdiary.premium.yearly"

    /// App Store Connect 自動續訂月訂產品 ID
    static let monthlyProductID = "com.kao.growdiary.premium.monthly"

    static let premiumProductIDs: Set<String> = [
        annualProductID,
        monthlyProductID
    ]

    /// 免費版可建立的檔案數上限
    static let freeProfileLimit = 1

    /// 免費版可查看的日記天數（自今日起算）
    static let freeDiaryHistoryDays = 30

    /// 行銷顯示價格（實際以 StoreKit 回傳為準）
    static let annualPriceDisplay = "NT$ 690"
    static let monthlyPriceDisplay = "NT$ 90"

    /// 無 StoreKit 價格時，計算年訂省幅用的 fallback 數值
    static let annualPriceAmount: Decimal = 690
    static let monthlyPriceAmount: Decimal = 90
}
