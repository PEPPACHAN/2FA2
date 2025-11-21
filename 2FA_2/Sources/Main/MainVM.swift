//
//  MainVM.swift
//  2FA_2
//
//  Created by PEPPA CHAN on 20.11.2025.
//


import Foundation
import Combine
import SwiftUI


final class MainVM: ObservableObject {
    @Published var tabs: MainPages = .accounts
    @Published var plusTapped = false
    @Published var showError = ""
    
}

enum MainPages: CaseIterable {
    case accounts
    case settings
    
    var title: some View {
        switch self {
        case .accounts: return Text("Accounts")
        case .settings: return Text("Settings")
        }
    }
    
    var image: Image {
        switch self {
        case .accounts: return Image(systemName: "list.bullet.rectangle.fill")
        case .settings: return Image(systemName: "gearshape.fill")
        }
    }
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .accounts: AccountsView()
        case .settings: SettingsView()
        }
    }
}
