//
//  SettingsView.swift
//  2FA_2
//
//  Created by PEPPA CHAN on 20.11.2025.
//


import SwiftUI
import StoreKit

struct SettingsView: View {
    
    @StateObject private var vm: SettingsVM = SettingsVM()
    @Environment(\.requestReview) private var requestReview
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Settings")
                .font(.system(size: 22, weight: .bold))
            
            ScrollView(showsIndicators: false) {
                ForEach(SettingsButtons.allCases, id: \.self) { button in
                    Button {
                        if button == SettingsButtons.rate {
                            requestReview()
                        } else if button == SettingsButtons.version {
                            vm.isAlert = true
                        } else if button == SettingsButtons.share {
                            let shareURL = button.url
                            if let url = URL(string: shareURL) {
                                let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                                
                                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                   let rootViewController = windowScene.windows.first?.rootViewController {
                                    rootViewController.present(activityVC, animated: true, completion: nil)
                                }
                            }
                        } else {
                            vm.url = button.url
                        }
                    } label: {
                        HStack(spacing: 12) {
                            button.image
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(.accent, button == SettingsButtons.version ? .white: .accent)
                            button.title
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(.black)
                        }
                        .frame(height: 68)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal)
        .background(Color.mainBG)
        .onChange(of: vm.url) { _ in
            if vm.url == "" {
                vm.isSheet = false
            } else {
                vm.isSheet = true
            }
        }
        .sheet(isPresented: $vm.isSheet) {
            if let url = URL(string: vm.url) {
                WebView(url: url)
            }
        }
        .alert("App Version", isPresented: $vm.isAlert) {
            Button("Ok", role: .cancel) {}
        } message: {
            Text(vm.appVersion)
        }
    }
}

#Preview {
    SettingsView()
}
