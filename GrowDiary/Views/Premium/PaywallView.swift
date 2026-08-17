import StoreKit
import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var subscriptionManager = SubscriptionManager.shared

    var body: some View {
        NavigationStack {
            ZStack {
                ScreenBackground()

                ScrollView {
                    VStack(spacing: 24) {
                        header
                        featureList
                        planPicker
                        actionButtons
                        legalFooter
                    }
                    .padding()
                }
            }
            .navigationTitle(L10n.string("premium.paywall.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.string("common.close")) { dismiss() }
                }
            }
            .alert(L10n.string("common.error.title"), isPresented: Binding(
                get: { subscriptionManager.errorMessage != nil },
                set: { if !$0 { subscriptionManager.errorMessage = nil } }
            )) {
                Button(L10n.string("common.ok")) {}
            } message: {
                Text(subscriptionManager.errorMessage ?? "")
            }
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .font(.system(size: 48))
                .foregroundStyle(AppTheme.babyPrimary)

            Text(L10n.string("premium.paywall.headline"))
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            Text(L10n.string("premium.paywall.subheadline"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }

    private var featureList: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(PremiumFeatureItem.allCases) { item in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(AppTheme.babyPrimary)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.title)
                            .font(.subheadline.weight(.semibold))
                        Text(item.subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(AppTheme.cardBackground, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
    }

    private var planPicker: some View {
        VStack(spacing: 12) {
            if let annual = subscriptionManager.annualProduct {
                planCard(
                    product: annual,
                    title: L10n.string("premium.paywall.plan.annual"),
                    periodLabel: L10n.string("premium.paywall.perYear"),
                    badge: L10n.string("premium.paywall.bestValue"),
                    savingsPercent: subscriptionManager.annualSavingsPercent
                )
            }

            if let monthly = subscriptionManager.monthlyProduct {
                planCard(
                    product: monthly,
                    title: L10n.string("premium.paywall.plan.monthly"),
                    periodLabel: L10n.string("premium.paywall.perMonth"),
                    badge: nil,
                    savingsPercent: nil
                )
            }

            if subscriptionManager.products.isEmpty {
                fallbackPricingCard
            }

            if subscriptionManager.selectedProductHasFreeTrial {
                Text(L10n.string("premium.paywall.trialBadge"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.babyPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(AppTheme.babySoft, in: Capsule())
            }
        }
    }

    private func planCard(
        product: Product,
        title: String,
        periodLabel: String,
        badge: String?,
        savingsPercent: Int?
    ) -> some View {
        let isSelected = subscriptionManager.selectedProductID == product.id

        return Button {
            subscriptionManager.selectedProductID = product.id
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)

                        if let badge {
                            Text(badge)
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(AppTheme.babyPrimary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(AppTheme.babySoft, in: Capsule())
                        }
                    }

                    Text("\(product.displayPrice) \(periodLabel)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let savingsPercent {
                        Text(L10n.format("premium.paywall.savePercent", savingsPercent))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppTheme.babyPrimary)
                    }
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? AppTheme.babyPrimary : .secondary)
            }
            .padding()
            .background(AppTheme.cardBackground, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(isSelected ? AppTheme.babyPrimary : Color.clear, lineWidth: 2)
            }
        }
        .buttonStyle(.plain)
    }

    private var fallbackPricingCard: some View {
        VStack(spacing: 8) {
            Text(SubscriptionConstants.annualPriceDisplay)
                .font(.title.bold())

            Text(L10n.string("premium.paywall.perYear"))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if let savings = subscriptionManager.annualSavingsPercent {
                Text(L10n.format("premium.paywall.savePercent", savings))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.babyPrimary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppTheme.cardBackground, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                Task { await subscriptionManager.purchase() }
            } label: {
                Group {
                    if subscriptionManager.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(subscriptionManager.selectedProductHasFreeTrial
                             ? L10n.string("premium.paywall.startTrial")
                             : L10n.string("premium.paywall.subscribe"))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.babyPrimary)
            .disabled(subscriptionManager.isLoading || subscriptionManager.selectedProduct == nil)

            Button {
                Task { await subscriptionManager.restorePurchases() }
            } label: {
                Text(L10n.string("premium.paywall.restore"))
            }
            .disabled(subscriptionManager.isLoading)
        }
    }

    private var legalFooter: some View {
        Text(L10n.string("premium.paywall.legal"))
            .font(.caption2)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.bottom, 8)
    }
}

private enum PremiumFeatureItem: CaseIterable, Identifiable {
    case profiles
    case diaryHistory
    case iCloud
    case backup
    case pdf
    case security
    case spotlight

    var id: String { title }

    var title: String {
        switch self {
        case .profiles: L10n.string("premium.feature.profiles.title")
        case .diaryHistory: L10n.string("premium.feature.diaryHistory.title")
        case .iCloud: L10n.string("premium.feature.icloud.title")
        case .backup: L10n.string("premium.feature.backup.title")
        case .pdf: L10n.string("premium.feature.pdf.title")
        case .security: L10n.string("premium.feature.security.title")
        case .spotlight: L10n.string("premium.feature.spotlight.title")
        }
    }

    var subtitle: String {
        switch self {
        case .profiles: L10n.string("premium.feature.profiles.subtitle")
        case .diaryHistory: L10n.string("premium.feature.diaryHistory.subtitle")
        case .iCloud: L10n.string("premium.feature.icloud.subtitle")
        case .backup: L10n.string("premium.feature.backup.subtitle")
        case .pdf: L10n.string("premium.feature.pdf.subtitle")
        case .security: L10n.string("premium.feature.security.subtitle")
        case .spotlight: L10n.string("premium.feature.spotlight.subtitle")
        }
    }
}

#Preview {
    PaywallView()
}
