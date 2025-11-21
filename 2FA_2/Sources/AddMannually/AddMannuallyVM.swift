//
//  AddMannuallyVM.swift
//  2FA_2
//
//  Created by PEPPA CHAN on 20.11.2025.
//


import Foundation


final class AddMannuallyVM: ObservableObject {
    @Published var key = ""
    @Published var name = ""
    @Published var service = ""
    @Published var showError = false
    
}

enum MannualTextFields: String, CaseIterable {
    case key = "Secret"
    case secret = "Name"
    case service = "Service"
    
    var placeholder: String {
        switch self {
            
        case .key: return "Min. 16 symbols"
        case .secret: return "Facebook Account"
        case .service: return "Facebook"
            
        }
    }
    
}
