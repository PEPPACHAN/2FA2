//
//  AccountsVM.swift
//  2FA_2
//
//  Created by PEPPA CHAN on 20.11.2025.
//

import Foundation
import Combine
import SwiftUI
import SwiftOTP


final class AccountsVM: ObservableObject {
    @Published var text: String = ""
    @Published var selectedTab = false
    @Published var itemForSheet: Accounts?
    
}
