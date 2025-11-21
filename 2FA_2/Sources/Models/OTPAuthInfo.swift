//
//  OTPAuthInfo.swift
//  2FA_2
//
//  Created by PEPPA CHAN on 20.11.2025.
//


import Foundation

struct OTPAuthInfo {
    let type: String
    let label: String
    let secret: String
    let issuer: String?
    let digits: Int
    let period: Int
}
