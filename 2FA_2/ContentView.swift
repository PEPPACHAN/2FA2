//
//  ContentView.swift
//  2FA_2
//
//  Created by PEPPA CHAN on 20.11.2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @EnvironmentObject private var pageManager: PageManager
    @State private var isEdit = false
    var body: some View {
        ZStack {
            switch pageManager.page {
            case .onboard: OnboardView()
            case .paywall: PaywallView().transition(.move(edge: .trailing))
            case .main: MainView().transition(.opacity)
            case .faq: FaqView().transition(.move(edge: .trailing))
            case .addManual: AddMannuallyView(isEdit: $isEdit).transition(.move(edge: .trailing))
            case .addQR: AddQRView().transition(.move(edge: .trailing))
            case .unknown: EmptyView()
            }
        }
        .animation(.easeInOut(duration: 0.2), value: pageManager.page)
            
    }
}


#Preview {
    ContentView()
//        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
