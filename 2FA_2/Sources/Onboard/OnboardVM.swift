//
//  OnboardVM.swift
//  2FA_2
//
//  Created by PEPPA CHAN on 20.11.2025.
//


import Foundation
import SwiftUI
import Combine
import UserNotifications
import AppTrackingTransparency

final class OnboardVM: ObservableObject {
    @Published var page: Pages = .first
    @Published var showPW: Bool = false
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .notDetermined {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                        if let error = error {
                            print("Ошибка при запросе доступа к уведомлениям: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
    
    func requestTrackingPermission() {
        if #available(iOS 14.5, *) {
            let status = ATTrackingManager.trackingAuthorizationStatus
            
            if status == .notDetermined {
                ATTrackingManager.requestTrackingAuthorization { status in
                    DispatchQueue.main.async {
                        switch status {
                        case .authorized:
                            print("Доступ к отслеживанию разрешен")
                        case .denied:
                            print("Доступ к отслеживанию отклонен")
                        case .restricted:
                            print("Доступ к отслеживанию ограничен")
                        case .notDetermined:
                            print("Статус доступа к отслеживанию не определен")
                        @unknown default:
                            print("Неизвестный статус доступа к отслеживанию")
                        }
                    }
                }
            }
        }
    }
    
}

enum Pages {
    case first
    case second
    case third
    case fourth
    
    var title: [String] {
        switch self {
        case .first: return ["User choice", "2FA Autenthicator"]
        case .second: return ["Create", "Accounts"]
        case .third: return ["We value", "your feedback"]
        case .fourth: return ["We value", "your feedback"]
        }
    }
    
    var description: String {
        switch self {
            case .first: return "Quickly access services using your one-time codes with time-based authentication"
            case .second: return "Provide your secret key, account name, and service details, we’ll take care of everything"
            case .third: return "Share your opinion about our app 2FA Autenthicator"
            case .fourth: return "Share your opinion about our app Journey To Stonehenge"
        }
    }
    
    var image: Image {
        switch self {
        case .first: return Image(._1)
        case .second: return Image(._2)
        case .third: return Image(._3)
        case .fourth: return Image(._4)
        }
    }
    
    mutating func next() {
        self = self.skipPage()
    }
    
    private func skipPage() -> Self {
        switch self {
        case .first: return .second
        case .second: return .third
        case .third: return .fourth
        case .fourth: return .fourth
        }
    }
}
