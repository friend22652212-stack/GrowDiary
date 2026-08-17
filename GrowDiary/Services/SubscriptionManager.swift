import Foundation
import StoreKit

@MainActor
final class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()

    @Published private(set) var isPremium = false
    @Published private(set) var products: [Product] = []
    @Published var selectedProductID = SubscriptionConstants.annualProductID
    @Published private(set) var isLoading = false
    @Published var showingPaywall = false
    @Published var errorMessage: String?

    private var transactionListener: Task<Void, Never>?

    private init() {
        transactionListener = listenForTransactions()
        Task {
            await loadProducts()
            await refreshEntitlements()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    var annualProduct: Product? {
        products.first { $0.id == SubscriptionConstants.annualProductID }
    }

    var monthlyProduct: Product? {
        products.first { $0.id == SubscriptionConstants.monthlyProductID }
    }

    var selectedProduct: Product? {
        products.first { $0.id == selectedProductID }
            ?? annualProduct
            ?? monthlyProduct
    }

    var selectedProductHasFreeTrial: Bool {
        selectedProduct?.subscription?.introductoryOffer != nil
    }

    /// 年訂相對月訂×12 的省幅百分比（四捨五入）
    var annualSavingsPercent: Int? {
        guard let annual = annualProduct, let monthly = monthlyProduct else {
            return Self.savingsPercent(
                annualPrice: SubscriptionConstants.annualPriceAmount,
                monthlyPrice: SubscriptionConstants.monthlyPriceAmount
            )
        }
        return Self.savingsPercent(annualPrice: annual.price, monthlyPrice: monthly.price)
    }

    func canAddProfile(currentCount: Int) -> Bool {
        isPremium || currentCount < SubscriptionConstants.freeProfileLimit
    }

    func requirePremium() -> Bool {
        if isPremium { return true }
        showingPaywall = true
        return false
    }

    func loadProducts() async {
        do {
            let loaded = try await Product.products(for: Array(SubscriptionConstants.premiumProductIDs))
            products = loaded.sorted { lhs, rhs in
                sortRank(for: lhs.id) < sortRank(for: rhs.id)
            }

            if !products.contains(where: { $0.id == selectedProductID }) {
                selectedProductID = annualProduct?.id ?? monthlyProduct?.id ?? SubscriptionConstants.annualProductID
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshEntitlements() async {
        var hasPremium = false

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            if SubscriptionConstants.premiumProductIDs.contains(transaction.productID),
               transaction.revocationDate == nil {
                hasPremium = true
            }
        }

        isPremium = hasPremium

        if !hasPremium {
            PremiumEntitlementEnforcer.applyFreeTierRestrictions()
        }
    }

    func purchase() async {
        guard let product = selectedProduct else {
            errorMessage = L10n.string("premium.error.productUnavailable")
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    await refreshEntitlements()
                    if isPremium {
                        showingPaywall = false
                    }
                }
            case .userCancelled:
                break
            case .pending:
                errorMessage = L10n.string("premium.error.pending")
            @unknown default:
                break
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func restorePurchases() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await AppStore.sync()
            await refreshEntitlements()
            if !isPremium {
                errorMessage = L10n.string("premium.error.noSubscription")
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func sortRank(for productID: String) -> Int {
        switch productID {
        case SubscriptionConstants.annualProductID: 0
        case SubscriptionConstants.monthlyProductID: 1
        default: 2
        }
    }

    private static func savingsPercent(annualPrice: Decimal, monthlyPrice: Decimal) -> Int? {
        let monthlyAnnualized = monthlyPrice * 12
        guard monthlyAnnualized > annualPrice, monthlyAnnualized > 0 else { return nil }

        let savings = (monthlyAnnualized - annualPrice) / monthlyAnnualized * 100
        var rounded = Decimal()
        var value = savings
        NSDecimalRound(&rounded, &value, 0, .plain)
        return max(1, (rounded as NSDecimalNumber).intValue)
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached {
            for await result in Transaction.updates {
                guard case .verified(let transaction) = result else { continue }
                await transaction.finish()
                await SubscriptionManager.shared.refreshEntitlements()
            }
        }
    }
}
