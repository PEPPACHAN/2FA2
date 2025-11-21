//
//  PaywallView.swift
//  2FA_2
//
//  Created by PEPPA CHAN on 20.11.2025.
//


import SwiftUI
import StoreKit
import ApphudSDK

struct PaywallView: View {
    @StateObject private var vm: PaywallVM = PaywallVM()
    @EnvironmentObject private var pm: PurchaseManager
    @EnvironmentObject var page: PageManager
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 24) {
                ForEach(Adventages.allCases, id: \.self) { adv in
                    HStack(alignment: .top, spacing: 9.64) {
                        Text(adv.rawValue)
                            .font(.system(size: 21.43, weight: .semibold))
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text(adv.title)
                                .font(.system(size: 18.21, weight: .bold))
                                .foregroundStyle(.white)
                            Text(adv.description)
                                .font(.system(size: 16.07))
                                .foregroundStyle(.white.opacity(0.8))
                        }
                    }
                }
            }
            .padding(.leading, 20)
            .padding(.trailing, 24.64)
            .padding(.bottom, 52)
            .overlay(alignment: .topTrailing) {
                Button {
                    page.page = .main
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(.white.opacity(0.5))
                        .padding(.trailing)
                }

            }
            
            Spacer()
            
            VStack(spacing: 0) {
                Text("Get Full Access")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.black)
                    .padding(.bottom, 5)
                
                Text("Audio & Video edit without linites")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.black.opacity(0.5))
                    .padding(.bottom)
                
                ForEach(pm.availableSubscriptions, id: \.self) { prod in
                    if let sub = prod.skProduct {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(pm.selectedSubscription == prod ? Color.accent: Color.black.opacity(0.15), lineWidth: pm.selectedSubscription == prod ? 2: 1)
                            .overlay {
                                HStack(spacing: 0) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(title(of: sub))
                                            .font(.system(size: 15, weight: .bold))
                                            .foregroundStyle(pm.selectedSubscription == prod ? .accent: .black)
                                             
                                        Text(subsDescription(of: sub))
                                            .font(.system(size: 13))
                                            .foregroundStyle(.black.opacity(0.5))
                                    }
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 3) {
                                        Text("\(sub.priceLocale.currencySymbol ?? "$")\(sub.price)")
                                        Text(period(of: sub))
                                    }
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(pm.selectedSubscription == prod ? .accent: .black)
                                }
                                .padding(.horizontal, 14)
                            }
                            .frame(height: 65)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay {
                                Rectangle()
                                    .frame(width: 1, height: 41)
                                    .foregroundStyle(.black.opacity(0.2))
                                    .padding(.leading, 39)
                            }
                            .padding(.bottom, pm.availableSubscriptions.first == prod ? 8: 20)
                            .padding(.horizontal)
                            .onTapGesture {
                                pm.selectedSubscription = prod
                            }
                            .animation(.default, value: pm.selectedSubscription)
                    }
                }
                
            }
            
            Text("Cancel anytime")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.black.opacity(0.5))
                .padding(.bottom, 8)
            
            Button {
                if let prod = pm.selectedSubscription {
                    Task {
                        await pm.purchase { res in
                            if res {
                                page.page = .main
                            }
                        }
                    }
                }
            } label: {
                Text("Continue")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
            }
            .padding(.bottom, 14)
            
            HStack {
                Button {
                    vm.url = "https://docs.google.com/document/d/1GdUE5bYvBfcMf9yHiiQ8Xw18ZSkyYx6Q4hErH-s4RYw/edit?usp=sharing"
                    vm.isSheet = true
                } label: {
                    Text("Terms of Use")
                }
                
                Spacer()
                
                Button {
                    vm.url = "https://docs.google.com/document/d/1TYLoSOtqqqDTOg-qQtRqCYxzrfxEcOu68_adX_hsZWw/edit?usp=sharing"
                    vm.isSheet = true
                } label: {
                    Text("Privacy Policy")
                }
                
                Spacer()
                
                Button {
                    pm.restorePurchases { res in
                        if res {
                            page.page = .main
                        }
                    }
                } label: {
                    Text("Restore")
                }
            }
            .font(.system(size: 13))
            .foregroundStyle(.black.opacity(0.5))
            .padding(.horizontal, 57)
            .padding(.bottom)
            
        }
        .padding(.top)
        .background(Image(.paywall).resizable().ignoresSafeArea())
        .onAppear {
            pm.loadPaywalls()
        }
        .onDisappear {
            vm.isFirst = false
        }
        .sheet(isPresented: $vm.isSheet) {
            if let url = URL(string: vm.url) {
                WebView(url: url)
                
            }
        }
    }
}


extension PaywallView {
    func title(of prod: SKProduct) -> String {
        switch prod.subscriptionPeriod?.unit {
        case .week: return "Weekly"
        case .year: return "Annual"
        
        case .none: return "No Product"
        case .some(_): return "Unknown Product"
        }
    }
    
    func subsDescription(of prod: SKProduct) -> String {
        switch prod.subscriptionPeriod?.unit {
        case .week: "Cancel anytime"
        case .year: "Best offer"
        case nil: "No Subscription"
        case .some(_): "Unknown Subscription"
        }
    }
    
    func period(of prod: SKProduct) -> String {
        switch prod.subscriptionPeriod?.unit {
            case .week: "/week"
            case .year: ""
            case nil: "/no period"
            case .some(_): "/unknown period"
        }
    }
}

#Preview {
    PaywallView()
}
