//
//  AddQRView.swift
//  2FA_2
//
//  Created by PEPPA CHAN on 20.11.2025.
//


import SwiftUI
import SwiftOTP

struct AddQRView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var page: PageManager
    @State private var lastScanned: String?
    private var vm = AddQRVM()
    
    var body: some View {
        ZStack {
            QRScannerView { url in
                // Проверяем, что это otpauth URL
                guard url.lowercased().hasPrefix("otpauth://") else {
                    print("QR-код не является otpauth URL: \(url)")
                    page.page = .main
                    return
                }
                
                // Парсим URL
                guard let parse = vm.parseOTPAuth(url: url) else {
                    print("Не удалось распарсить otpauth URL: \(url)")
                    page.page = .main
                    return
                }
                
                // Очищаем пробелы из секрета и декодируем base32
                let cleanedSecret = parse.secret.replacingOccurrences(of: " ", with: "")
                guard let secretData = base32DecodeToData(cleanedSecret) else {
                    print("Не удалось декодировать base32 секрет: \(cleanedSecret)")
                    page.page = .main
                    return
                }
                
                // Создаем TOTP генератор
                let totp = TOTP(secret: secretData, digits: parse.digits, timeInterval: parse.period, algorithm: .sha1)
                let time = Date()
                guard let code = totp?.generate(time: time) else {
                    print("Не удалось сгенерировать TOTP код")
                    page.page = .main
                    return
                }
                
                // Определяем имя аккаунта (приоритет: issuer > label)
                let accountName = parse.issuer ?? parse.label
                
                // Сохраняем аккаунт
                CoreDataManager(vc: viewContext).addAccount(
                    code: code,
                    key: parse.secret,
                    name: accountName,
                    service: parse.label,
                    url: url,
                    timestamp: time,
                    digit: parse.digits,
                    interval: parse.period
                )
                
                print("Аккаунт успешно добавлен: \(accountName)")
                page.page = .main
            }
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Button(action: { page.page = .main }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                    }
                    Spacer()
                }
                Spacer()
            }
            
            Image(.scanFrames)
        }
    }
}

#Preview {
    AddQRView()
}
