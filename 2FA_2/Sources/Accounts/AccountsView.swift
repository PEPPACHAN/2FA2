//
//  AccountsView.swift
//  2FA_2
//
//  Created by PEPPA CHAN on 20.11.2025.
//

import SwiftUI
import Combine
import SwiftOTP
import CoreData

struct AccountsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Accounts.name, ascending: true)],
        animation: .default)
    private var accounts: FetchedResults<Accounts>
    
    @StateObject private var vm: AccountsVM = AccountsVM()
    @EnvironmentObject private var pageManager: PageManager
    @FocusState private var isSearch
    
    private var filteredAccs: [Accounts] {
        if vm.text.isEmpty && !vm.selectedTab {
            return Array(accounts)
        } else if !vm.text.isEmpty {
            return accounts.filter {
                $0.name?.lowercased().contains(vm.text.lowercased()) ?? false
            }
        } else if vm.selectedTab {
            return accounts.filter { $0.isFavorite == true }
        }
        
        return Array(accounts)
    }
    
    @State private var currentTime = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                LinearGradient(colors: [.gradientStart, .accent], startPoint: .top, endPoint: .bottom)
                    .onTapGesture {
                        if isSearch {
                            isSearch = false
                        }
                    }
                
                VStack(spacing: 24) {
                    Text("Authenticator")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                        .onTapGesture {
                                if isSearch {
                                    isSearch = false
                                }
                        }
                    
                    HStack(spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.white)
                            
                            ZStack(alignment: .leading) {
                                if vm.text.isEmpty {
                                    Text("Search for Accounts")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(.white.opacity(0.6))
                                }
                                TextField("", text: $vm.text)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(.white)
                                    .focused($isSearch)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 45)
                        .padding(.horizontal, 14)
                        .background(Color.white.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        Button {
                            pageManager.page = .faq
                        } label: {
                            Image(.infoCircle)
                                .frame(width: 45, height: 45)
                                .background(Color.white.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        
                    }
                    .padding(.horizontal)
                    
                }
                .offset(y: 20)
                
            }
            .ignoresSafeArea()
            .frame(height: 130)
            
            if accounts.isEmpty {
                VStack {
                    Text("Add your first 2FA code")
                        .font(.system(size: 20, weight: .semibold))
                    
                    Text("Secure your accounts by adding two-factor authentication")
                        .font(.system(size: 15, weight: .medium))
                        .opacity(0.6)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundStyle(.black)
                .multilineTextAlignment(.center)
            } else {
                VStack(spacing: 0) {
                    GeometryReader { proxy in
                        Color.accent.opacity(0.3)
                            .frame(height: 49)
                            .overlay(alignment: !vm.selectedTab ? .leading: .trailing, content: {
                                Color.accent
                                    .frame(width: proxy.frame(in: .local).width/2)
                            })
                            .overlay {
                                HStack(spacing: 0) {
                                    Text("All")
                                        .frame(width: proxy.frame(in: .local).width/2, alignment: .center)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            vm.selectedTab = false
                                            
                                            if isSearch {
                                                isSearch = false
                                            }
                                        }
                                    
                                    Text("Favorites")
                                        .frame(width: proxy.frame(in: .local).width/2, alignment: .center)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            vm.selectedTab = true
                                            
                                            if isSearch {
                                                isSearch = false
                                            }
                                        }
                                }
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .frame(height: 49)
                    .padding(.top)
                    .padding(.bottom)
                    
                    ScrollView {
                        ForEach(filteredAccs, id: \.self) { acc in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(acc.name ?? "No name")
                                        .font(.system(size: 15, weight: .medium))
                                    
                                    if let code = acc.code {
                                        Text(threeDigitFormatted(of: code))
                                            .font(.system(size: 22, weight: .bold))
                                            .foregroundStyle(.accent)
                                    }
                                }
                                
                                Spacer()
                                
                                var progress: Double {
                                    if let time = acc.timestamp {
                                        return Double(time.timeIntervalSince1970-currentTime.timeIntervalSince1970)/Double(acc.interval)
                                    }
                                    
                                    return Double(0)
                                }
                                
                                Circle()
                                    .stroke(lineWidth: 5)
                                    .foregroundStyle(.accent.opacity(0.2))
                                    .frame(width: 44, height: 44)
                                    .overlay {
                                        Circle()
                                            .trim(from: 0, to: progress)
                                            .stroke(
                                                Color.accent,
                                                style: StrokeStyle(
                                                    lineWidth: 5,
                                                    lineCap: .round,
                                                    lineJoin: .round
                                                )
                                            )
                                            .foregroundStyle(.accent)
                                            .rotationEffect(.degrees(-90))
                                            .scaleEffect(x: -1, y: 1)
                                    }
                                    .onReceive(timer) { now in
                                        currentTime = now
                                        remaindTime(acc: acc)
                                    }
                                
                            }
                            .padding(14)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .onTapGesture {
                                vm.itemForSheet = acc
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 13)
            }
        }
        .animation(.bouncy, value: vm.selectedTab)
        .animation(.interactiveSpring, value: vm.text)
        .sheet(item: $vm.itemForSheet) { _ in
            DetailSheetView(vc: viewContext, account: $vm.itemForSheet)
                .presentationDetents([.height(333)])
                .presentationDragIndicator(.visible)
        }
    }
}

extension AccountsView {
    private func remaindTime(acc: Accounts) {
        let left = (acc.timestamp?.timeIntervalSince1970 ?? 0)-currentTime.timeIntervalSince1970
        
        if left <= 0 {
            DispatchQueue.main.async {
                if let secret = acc.secret?.replacingOccurrences(of: " ", with: "") {
                    if let data = base32DecodeToData(secret) {
                        let totp = TOTP(secret: data, digits: Int(acc.digit), timeInterval: Int(acc.interval), algorithm: .sha1)
                        let time = Date()
                        let code = totp?.generate(time: time)
                        
                        acc.code = code
                        acc.timestamp = time.addingTimeInterval(30)
                        
                        do {
                            try viewContext.save()
                        } catch {
                            print("[AccountsView] Cant update timer")
                        }
                        
                    }
                }
            }
            
        }
    }
}


extension AccountsView {
    
    func threeDigitFormatted(of string: String) -> String {
        let res = string.replacingOccurrences(
            of: "(\\d{3})(?=\\d)",
            with: "$1 ",
            options: .regularExpression
        )
        .trimmingCharacters(in: .whitespaces)
        
        return res
    }
    
}


#Preview {
    AccountsView()
}
