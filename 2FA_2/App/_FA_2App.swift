//
//  _FA_2App.swift
//  2FA_2
//
//  Created by PEPPA CHAN on 20.11.2025.
//

import SwiftUI
import Combine
import CoreData

@main
struct _FA_2App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("isFirst") var isFirst: Bool = true
    let persistenceController = PersistenceController.shared
    @StateObject private var pageManager: PageManager = PageManager()
    @StateObject private var pm: PurchaseManager = PurchaseManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    pageManager.page.checkPage(isFirst)
                }
                .colorScheme(.light)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(pageManager)
                .environmentObject(pm)
                
        }
    }
    
    
}


    
final class PageManager: ObservableObject {
    @Published var page: Page = .unknown
}

enum Page {
    case onboard
    case paywall
    case main
    case faq
    case addManual
    case addQR
    case unknown
    
    mutating func checkPage(_ first: Bool) {
        if first {
            self = .onboard
        } else {
            self = .main
        }
    }
}

