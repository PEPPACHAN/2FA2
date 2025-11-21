//
//  PurchaseManager.swift
//  2FA_2
//
//  Created by PEPPA CHAN on 20.11.2025.
//


import Foundation
import StoreKit
import Combine
import ApphudSDK

final class PurchaseManager: ObservableObject {
//    private let subscriptionIDs = [
//        "week_3.99_nottrial_z",
//        "yearly_39.99_nottrial_z"
//    ]
    private var subscriptionIDs: [String] = []
    private let paywallID = "main"
    
    @Published private(set) var availableSubscriptions: [ApphudProduct] = []
    @Published private(set) var activeSubscriptions = Set<String>()
    @Published var selectedSubscription: ApphudProduct?
    
//    private var updatesTask: Task<Void, Never>? = nil
    private var productsFetched = false
    
    //    init() {
    //            do {
    //                try await fetchProducts()
    //                await refreshActiveSubscriptions()
    //            } catch {
    //                print("Failed to initialize store: \(error.localizedDescription)")
    //            }
    //        }
    //
    //            updatesTask = watchForTransactions()
    //    }
    //
    //    deinit {
    //        updatesTask?.cancel()
    //    }
    
    var hasActiveSubscription: Bool {
        Apphud.hasActiveSubscription()
    }
    
    
    @MainActor func loadPaywalls() {
        Apphud.paywallsDidLoadCallback { pw, err in
            if let error = err {
                print(error.localizedDescription)
            }
            
            if let paywall = pw.first(where: { $0.identifier == self.paywallID}) {
                Apphud.paywallShown(paywall)
                self.availableSubscriptions = paywall.products
                self.selectedSubscription = paywall.products.first
            }
            
        }
    }
    
//    func fetchProducts() async throws {
//        guard !productsFetched else { return }
//        let products = try await Product.products(for: subscriptionIDs)
//        availableSubscriptions = products.sorted { $0.price < $1.price }
//        selectedSubscription = availableSubscriptions.first
//        productsFetched = true
//    }
    
    @MainActor func purchase(escaping: @escaping(Bool) -> Void ) async {
        guard let sub = selectedSubscription else { return }
        Apphud.purchase(sub) { result in
            if let error = result.error {
                debugPrint(error.localizedDescription)
                escaping(false)
            } else if let subs = result.subscription, subs.isActive() {
                escaping(true)
            } else {
                if Apphud.hasActiveSubscription() {
                    escaping(true)
                }
            }
        }
            
//            switch result {
//            case .success(let verification):
//                let transaction = try verify(verification)
//                await transaction.finish()
//                await refreshActiveSubscriptions()
//                print("Purchase completed: \(transaction.productID)")
//                
//            case .userCancelled:
//                print("User cancelled purchase")
//            case .pending:
//                print("Purchase pending approval")
//            @unknown default:
//                print("Unknown purchase result")
//            }
            
    }
    
    @MainActor func restorePurchases(escaping: @escaping(Bool)->Void) {
        Apphud.restorePurchases { subs, _, err in
            if let error = err {
                debugPrint(error.localizedDescription)
                escaping(false)
            }
            if subs?.first?.isActive() ?? false {
                escaping(true)
                return
            }
            
            if Apphud.hasActiveSubscription() {
                escaping(true)
            }
        }
//        { res in
//            if let err = res.error {
//                debugPrint(err.localizedDescription)
//                escaping(false)
//            }
//            if res.subscription?.isActive() ?? false {
//                escaping(true)
//                return
//            }
//            
//            if Apphud.hasActiveSubscription() {
//                escaping(true)
//            }
//        }
    }
    
//    func refreshActiveSubscriptions() async {
//        var currentSubscriptions = Set<String>()
//        for await result in Transaction.currentEntitlements {
//            guard case .verified(let transaction) = result else { continue }
//            
//            if transaction.revocationDate == nil {
//                currentSubscriptions.insert(transaction.productID)
//            } else {
//                currentSubscriptions.remove(transaction.productID)
//            }
//        }
//        
//        activeSubscriptions = currentSubscriptions
//    }
//    
//    private func watchForTransactions() -> Task<Void, Never> {
//        Task(priority: .background) {
//            for await result in Transaction.updates {
//                do {
//                    let transaction = try verify(result)
//                    print("Updated transaction for: \(transaction.productID)")
//                    await transaction.finish()
//                } catch {
//                    print("Transaction verification failed: \(error.localizedDescription)")
//                }
//                await refreshActiveSubscriptions()
//            }
//        }
//    }
//    
//    private func verify<T>(_ result: VerificationResult<T>) throws -> T {
//        switch result {
//        case .verified(let transaction):
//            return transaction
//        case .unverified(_, let error):
//            throw error
//        }
//    }
}
