//
//  OnboardView.swift
//  2FA_2
//
//  Created by PEPPA CHAN on 20.11.2025.
//


import SwiftUI
import StoreKit

struct OnboardView: View {
    
    @Environment(\.requestReview) private var review
    @StateObject private var vm: OnboardVM = OnboardVM()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Spacer()
                
                Text(vm.page.title.first ?? "No title")
                    .font(.system(size: 28, weight: .heavy))
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.center)
                Text(vm.page.title.last ?? "No title")
                    .font(.system(size: 28, weight: .heavy))
                    .foregroundStyle(.accent)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 8)
                
                Text(vm.page.description)
                    .font(.system(size: 17))
                    .foregroundStyle(.black.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.bottom)
                
                Button {
                    if vm.page == .first {
                        vm.requestNotificationPermission()
                        vm.page.next()
                    } else if vm.page == .third {
                        review()
                        vm.page.next()
                    } else if vm.page != .fourth {
                        vm.page.next()
                    } else {
                        vm.showPW = true
                    }
                } label: {
                    Text("Continue")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 20)
                        .padding(.vertical)
                        .background(Color.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.bottom, 19)
                }
                
            }
            .padding(.horizontal, 20)
            .background(vm.page.image.resizable().ignoresSafeArea())
            .animation(.linear, value: vm.page)
            .navigationDestination(isPresented: $vm.showPW) {
                PaywallView()
                    .navigationBarBackButtonHidden()
            }
            .onAppear {
                vm.requestTrackingPermission()
            }
        }
    }
}

#Preview {
    OnboardView()
}
