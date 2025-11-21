//
//  FaqData.swift
//  2FA_2
//
//  Created by PEPPA CHAN on 20.11.2025.
//


import Foundation

struct FaqData {

    let firstDescr = "An Authenticator app is a tool that generates secure, one-time passcodes for two-factor authentication (2FA). It adds an extra layer of protection to your online accounts."

    let firstListTitle = [
        "Set up 2FA:",
        "Add the key to your Authenticator:",
        "Secure connection:",
        "Code generation:"
    ]

    let firstListDescr = [
        "When you enable two-factor authentication on your account, the website or app provides a secret key, usually shown as a QR code.",
        "Scan the QR code or manually enter the secret key into your Authenticator app.",
        "This creates a secure link between your account and the Authenticator app, ensuring that only your device can generate valid codes.",
        "The Authenticator produces a 6–8 digit code that changes every few seconds. To log in, you’ll need to enter this code in addition to your password."
    ]
    
    let secondListDescr = [
        "Even if someone knows your password, they can’t access your account without the 2FA code.",
        "The codes are temporary and unique, making them extremely difficult to guess.",
        "This provides an extra layer of security for your personal information."
    ]
    
    let endingDescr = "Each website or service has its own instructions for turning on two-factor authentication. You can usually find them in your account’s Security or Privacy settings."
    
}
