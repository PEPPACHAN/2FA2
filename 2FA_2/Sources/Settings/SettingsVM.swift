//
//  SettingsVM.swift
//  2FA_2
//
//  Created by PEPPA CHAN on 20.11.2025.
//


import Foundation
import Combine
import SwiftUI


final class SettingsVM: ObservableObject {
    @Published var url = ""
    @Published var isSheet = false
    @Published var isAlert = false
    
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
}

enum SettingsButtons: CaseIterable {
    case rate
    case support
    case share
    case version
    case privacy
    case terms
    
    var title: some View {
        switch self {
        case .rate: return Text("Rate App")
        case .support: return Text("Support")
        case .share: return Text("Share App")
        case .version: return Text("App version")
        case .privacy: return Text("Privacy Policy")
        case .terms: return Text("Term of Use")
        }
    }
    
    var image: Image {
        switch self {
        case .rate: return Image(systemName: "star")
        case .support: return Image(systemName: "exclamationmark.bubble")
        case .share: return Image(systemName: "bubble.left.and.text.bubble.right")
        case .version: return Image(systemName: "smartphone")
        case .privacy: return Image(systemName: "shield.righthalf.filled")
        case .terms: return Image(systemName: "text.page")
        }
    }
    
    var url: String {
        switch self {
        case .rate: return ""
        case .support: return "https://docs.google.com/forms/d/e/1FAIpQLSdYoIiOYF7JbKXl6ziixZLIWAxK7Q7deHez6Y4hpeUcnK9DfQ/viewform?usp=publish-editor"
        case .share: return "https://apps.apple.com/us/app/zyntrio-2fa-authenticator/id6755149662"
        case .version: return ""
        case .privacy: return "https://docs.google.com/document/d/1TYLoSOtqqqDTOg-qQtRqCYxzrfxEcOu68_adX_hsZWw/edit?usp=sharing"
        case .terms: return "https://docs.google.com/document/d/1GdUE5bYvBfcMf9yHiiQ8Xw18ZSkyYx6Q4hErH-s4RYw/edit?usp=sharing"
        }
    }
}
