//
//  CoreDataManager.swift
//  2FA_2
//
//  Created by PEPPA CHAN on 20.11.2025.
//


import Foundation
import SwiftUI
import CoreData

final class CoreDataManager {
    var vc: NSManagedObjectContext
    
    init(vc: NSManagedObjectContext) {
        self.vc = vc
    }
    
    
    func addAccount(code: String, key: String, name: String, service: String, url: String = "", timestamp: Date = Date(), digit: Int, interval: Int) {
        let newItem = Accounts(context: vc)
        newItem.code = code
        newItem.secret = key
        newItem.name = name
        newItem.service = service
        newItem.url = url
        newItem.timestamp = timestamp.addingTimeInterval(30)
        newItem.digit = Int16(digit)
        newItem.interval = Int16(interval)
        
        try? vc.save()
    }
    
    func deleteAccount(account: Accounts) {
        vc.delete(account)
        
        do {
            try vc.save()
        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
}
