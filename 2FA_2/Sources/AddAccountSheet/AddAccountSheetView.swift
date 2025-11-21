//
//  AddAccountSheetView.swift
//  2FA_2
//
//  Created by PEPPA CHAN on 20.11.2025.
//


import SwiftUI
import PhotosUI
import SwiftOTP

struct AddAccountSheetView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var page: PageManager
    @StateObject private var vm: AddAccountSheetVM = AddAccountSheetVM()
    @Binding var showError: String
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(AddAccountButtons.allCases, id: \.self) { button in
                
                Button (action: {
                    if button == AddAccountButtons.manual {
                        page.page = .addManual
                    } else if button == AddAccountButtons.scan {
                        page.page = .addQR
                    } else if button == AddAccountButtons.photo {
                        vm.isShowPicker = true
                    }
                }, label: {
                    HStack(spacing: 8) {
                        button.image
                        Text(button.rawValue)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.black)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Color.addAccountButton)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                })
                
            }
        }
        .padding(.vertical)
        .onAppear {
            vm.requestPhotoLibraryAccess()
        }
        .photosPicker(isPresented: $vm.isShowPicker, selection: $vm.selectedItem, matching: .images)
        .onChange(of: vm.selectedItem) { _ in
            Task {
                guard let selectedItem = vm.selectedItem else { return }
                
                // Загружаем изображение через Data (UIImage не соответствует Transferable)
                if let data = try? await selectedItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    vm.detectQRCode(in: image)
                } else {
                    print("Не удалось загрузить изображение из PhotosPicker")
                    
                    DispatchQueue.main.async {
                        vm.isShowPicker = false
                        showError = "Couldn't upload image"
                    }
                }
            }
        }
        .onChange(of: vm.qrCode) { newValue in
            guard let qr = newValue, !qr.isEmpty else {
                // QR-код не найден или пустой - ничего не делаем
                return
            }
            
            print("Найден QR-код: \(qr)")
            
            // Проверяем, что это otpauth URL
            guard qr.lowercased().hasPrefix("otpauth://") else {
                print("QR-код не является otpauth URL: \(qr)")
                showError = "QR code doesn't contain TOTP url"
                return
            }
            
            // Парсим URL
            guard let parse = vm.parseOTPAuth(url: qr) else {
                print("Не удалось распарсить otpauth URL: \(qr)")
                showError = "Invalid url"
                return
            }
            
            // Очищаем пробелы из секрета и декодируем base32
            let cleanedSecret = parse.secret.replacingOccurrences(of: " ", with: "")
            guard let secretData = base32DecodeToData(cleanedSecret) else {
                print("Не удалось декодировать base32 секрет: \(cleanedSecret)")
                showError = "Couldn't decode secret"
                return
            }
            
            // Создаем TOTP генератор
            let totp = TOTP(secret: secretData, digits: parse.digits, timeInterval: parse.period, algorithm: .sha1)
            let time = Date()
            guard let code = totp?.generate(time: time) else {
                print("Не удалось сгенерировать TOTP код")
                showError = "Couldn't generate TOTP code"
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
                url: qr,
                timestamp: time,
                digit: parse.digits,
                interval: parse.period
            )
            
            // Закрываем picker
            vm.isShowPicker = false
            
            print("Аккаунт успешно добавлен: \(accountName)")
        }
    }
}

//#Preview {
//    AddAccountSheetView()
//}
