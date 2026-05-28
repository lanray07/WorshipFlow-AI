import Foundation
import Observation
import StoreKit

@MainActor
@Observable
final class SubscriptionService {
    struct FallbackOffer: Identifiable {
        let id: String
        let title: String
        let duration: String
        let price: String
        let features: [String]
    }

    static let productIDs = [
        "worshipflow.pro.monthly",
        "worshipflow.pro.yearly",
        "worshipflow.church.monthly"
    ]

    static let fallbackOffers: [FallbackOffer] = [
        FallbackOffer(
            id: "worshipflow.pro.monthly",
            title: "WorshipFlow AI Pro Monthly",
            duration: "1 month, auto-renewing",
            price: "GBP 9.99 per month",
            features: ["Unlimited set lists", "Lyric prompter", "Key transposer", "Volunteer scheduling", "PDF exports", "AI worship flow suggestions"]
        ),
        FallbackOffer(
            id: "worshipflow.pro.yearly",
            title: "WorshipFlow AI Pro Yearly",
            duration: "1 year, auto-renewing",
            price: "GBP 79.99 per year",
            features: ["Everything in Pro Monthly", "Best value for year-round planning", "Annual worship-team workflow support"]
        ),
        FallbackOffer(
            id: "worshipflow.church.monthly",
            title: "WorshipFlow AI Church Monthly",
            duration: "1 month, auto-renewing",
            price: "GBP 29.99 per month",
            features: ["Multiple worship teams", "Advanced scheduling", "Team collaboration placeholder", "Admin controls placeholder", "Cloud sync placeholder"]
        )
    ]

    var products: [Product] = []
    var purchasedProductIDs: Set<String> = []
    var isLoading = false
    var isPurchasingProductID: String?
    var errorMessage: String?

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        do {
            products = try await Product.products(for: Self.productIDs)
                .sorted { lhs, rhs in
                    (Self.productIDs.firstIndex(of: lhs.id) ?? 0) < (Self.productIDs.firstIndex(of: rhs.id) ?? 0)
                }
            await refreshEntitlements()
        } catch {
            errorMessage = "Subscriptions are temporarily unavailable. Please try again later."
        }
    }

    func purchase(_ product: Product) async {
        isPurchasingProductID = product.id
        defer { isPurchasingProductID = nil }
        do {
            let result = try await product.purchase()
            if case .success(let verification) = result, case .verified(let transaction) = verification {
                purchasedProductIDs.insert(transaction.productID)
                await transaction.finish()
            } else if case .success = result {
                errorMessage = "We could not verify this purchase. Please try again."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await refreshEntitlements()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshEntitlements() async {
        purchasedProductIDs.removeAll()
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                purchasedProductIDs.insert(transaction.productID)
            }
        }
    }
}
