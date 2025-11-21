//
//  AppDelegate.swift
//  2FA_2
//
//  Created by PEPPA CHAN on 20.11.2025.
//


import Foundation
import SwiftUI
import ApphudSDK
import AppTrackingTransparency
import AdSupport


class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        configureHapticFeedback()
        hudConfig()
        
        return true
    }
    
    
    private func hudConfig() {
        Apphud.start(apiKey: "app_MtkT8hnbvsERWumW42ZZFrzRs4vXho")
        Apphud.setDeviceIdentifiers(idfa: nil, idfv: UIDevice.current.identifierForVendor?.uuidString)
        fetchIDFA()
    }
    
    private func fetchIDFA() {
        
        if #available(iOS 14.5, *) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    switch status {
                    case .authorized:
                        let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                        Apphud.setDeviceIdentifiers(idfa: idfa, idfv: UIDevice.current.identifierForVendor?.uuidString)
                        
                    case .denied:
                        print("Tracking authorization denied by the user.")
                        
                    case .restricted:
                        print("Tracking is restricted (e.g., parental controls).")
                        
                    case .notDetermined:
                        print("Tracking authorization has not been determined.")
                        
                    @unknown default:
                        print("Unexpected tracking status.")
                    }
                }
            }
        }
        
    }
    
    private func configureHapticFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
    }
    
}
