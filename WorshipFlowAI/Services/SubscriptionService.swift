import Foundation
import Observation
import StoreKit

@MainActor
@Observable
final class SubscriptionService {
    static let productIDs = [
        "worshipflow.pro.monthly",
        "worshipflow.pro.yearly",
        "worshipflow.church.monthly"
    ]

    var products: [Product] = []
    var purchasedProductIDs: Set<String> = []
    var isLoading = false
    var errorMessage: String?

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        do {
            products = try await Product.products(for: Self.productIDs)
            await refreshEntitlements()
        } catch {
            errorMessage = "StoreKit products are not configured yet. Placeholder pricing is shown."
        }
    }

    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            if case .success(let verification) = result, case .verified(let transaction) = verification {
                purchasedProductIDs.insert(transaction.productID)
                await transaction.finish()
            }
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
