//
//  PaywallVM.swift
//  2FA_2
//
//  Created by PEPPA CHAN on 20.11.2025.
//


import Foundation
import Combine
import SwiftUI

final class PaywallVM: ObservableObject {
    @AppStorage("isFirst") var isFirst: Bool = true
    @Published var isSheet = false
    @Published var url = ""
    
}

enum Adventages: String, CaseIterable {
    case puzzle = "🧩"
    case gear = "⚙️"
    case disc = "💾"
    case stars = "✨"
    
    var title: String {
        switch self {
        case .puzzle: return "Unlimited Accounts"
        case .gear: return "Advanced Code Protection"
        case .disc: return "No-Limit Backup Storage"
        case .stars: return "Exclusive Sync Support"
        }
    }
    
    var description: String {
        switch self {
        case .puzzle: return "Create unlimited accounts – keep all your codes securely stored in one place"
        case .gear: return "Your tokens are encrypted on your device, keeping them offline!"
        case .disc: return "Keep your authentication keys safe by using encrypted storage"
        case .stars: return "Quickly and securely transfer tokens between devices"
        }
    }
    
}
