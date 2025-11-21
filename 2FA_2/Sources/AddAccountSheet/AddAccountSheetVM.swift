//
//  AddAccountSheetVM.swift
//  2FA_2
//
//  Created by PEPPA CHAN on 20.11.2025.
//


import Foundation
import SwiftUI
import Combine
import PhotosUI
import Photos
import Vision
import CoreImage


final class AddAccountSheetVM: ObservableObject {
    
    @Published var selectedItem: PhotosPickerItem?
    @Published var selectedImageData: Data?
    @Published var qrCode: String?
    @Published var isShowPicker = false
    
    func requestPhotoLibraryAccess() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    // Доступ запрошен, статус обновлен
                }
            }
        case .denied, .restricted:
            // Доступ запрещен или ограничен
            break
        case .authorized, .limited:
            // Доступ уже предоставлен
            break
        @unknown default:
            break
        }
    }
    
    func detectQRCode(in image: UIImage) {
        // Выполняем обработку в фоновом потоке
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            // Получаем CGImage
            guard let sourceCGImage = image.cgImage else {
                print("Ошибка: Не удалось получить CGImage из UIImage")
                DispatchQueue.main.async {
                    self.qrCode = nil
                }
                return
            }
            
            // Создаем CIImage для обработки
            var ciImage = CIImage(cgImage: sourceCGImage)
            
            // Исправляем ориентацию через Core Image трансформацию
            if image.imageOrientation != .up {
                let transform: CGAffineTransform
                switch image.imageOrientation {
                case .down:
                    transform = CGAffineTransform(translationX: ciImage.extent.width, y: ciImage.extent.height)
                        .rotated(by: .pi)
                case .left:
                    transform = CGAffineTransform(translationX: ciImage.extent.height, y: 0)
                        .rotated(by: .pi / 2)
                case .right:
                    transform = CGAffineTransform(translationX: 0, y: ciImage.extent.width)
                        .rotated(by: -.pi / 2)
                default:
                    transform = .identity
                }
                ciImage = ciImage.transformed(by: transform)
            }
            
            // Масштабируем при необходимости через Core Image
            let maxDimension: CGFloat = 2048
            let extent = ciImage.extent
            let maxSize = max(extent.width, extent.height)
            
            if maxSize > maxDimension {
                let scale = maxDimension / maxSize
                let transform = CGAffineTransform(scaleX: scale, y: scale)
                ciImage = ciImage.transformed(by: transform)
            }
            
            // Создаем новый CGImage через CIContext для обеспечения правильного формата
            let context = CIContext(options: [
                .workingColorSpace: NSNull(),
                .outputColorSpace: CGColorSpaceCreateDeviceRGB()
            ])
            
            guard let finalCGImage = context.createCGImage(ciImage, from: ciImage.extent) else {
                print("Ошибка: Не удалось создать CGImage через CIContext")
                DispatchQueue.main.async {
                    self.qrCode = nil
                }
                return
            }
            
            // Проверяем валидность
            guard finalCGImage.width > 0 && finalCGImage.height > 0,
                  finalCGImage.colorSpace != nil else {
                print("Ошибка: Изображение некорректно")
                DispatchQueue.main.async {
                    self.qrCode = nil
                }
                return
            }
            
            // Создаем запрос на распознавание
            let request = VNDetectBarcodesRequest { [weak self] request, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Ошибка при распознавании QR-кода: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.qrCode = nil
                    }
                    return
                }
                
                guard let results = request.results as? [VNBarcodeObservation] else {
                    DispatchQueue.main.async {
                        self.qrCode = nil
                    }
                    return
                }
                
                if let first = results.first(where: { $0.payloadStringValue != nil }) {
                    DispatchQueue.main.async {
                        self.qrCode = first.payloadStringValue
                    }
                } else {
                    DispatchQueue.main.async {
                        self.qrCode = nil
                    }
                }
            }
            
            // Указываем только QR-коды
            request.symbologies = [.QR]
            
            // Создаем handler с изображением, обработанным через CIContext
            let handler = VNImageRequestHandler(cgImage: finalCGImage, orientation: .up, options: [:])
            
            // Выполняем запрос
            do {
                try handler.perform([request])
            } catch {
                print("Ошибка при выполнении Vision запроса: \(error.localizedDescription)")
                print("  - Код ошибки: \((error as NSError).code)")
                print("  - Примечание: Ошибка может возникать на симуляторе. Попробуйте на реальном устройстве.")
                DispatchQueue.main.async {
                    self.qrCode = nil
                }
            }
        }
    }
    
    func parseOTPAuth(url: String) -> OTPAuthInfo? {
        // Проверяем, что это otpauth URL
        guard url.lowercased().hasPrefix("otpauth://") else {
            print("URL не является otpauth: \(url)")
            return nil
        }
        
        // Парсим URL
        guard let components = URLComponents(string: url) else {
            print("Не удалось разобрать URL: \(url)")
            return nil
        }
        
        // Проверяем схему
        guard components.scheme?.lowercased() == "otpauth" else {
            print("Неправильная схема URL: \(components.scheme ?? "nil")")
            return nil
        }
        
        // Проверяем тип (totp или hotp)
        guard let host = components.host?.lowercased(), 
              host == "totp" || host == "hotp" else {
            print("Неправильный тип OTP: \(components.host ?? "nil")")
            return nil
        }
        
        // Извлекаем label из path (URLComponents автоматически декодирует символы)
        var label = components.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        
        // Извлекаем query параметры (URLComponents автоматически декодирует значения)
        var queryItems: [String: String] = [:]
        components.queryItems?.forEach { item in
            // Сохраняем декодированное значение
            queryItems[item.name.lowercased()] = item.value
        }
        
        // Секретный ключ обязателен
        guard let secret = queryItems["secret"], !secret.isEmpty else {
            print("Секретный ключ отсутствует в URL")
            return nil
        }
        
        // Извлекаем остальные параметры
        let issuer = queryItems["issuer"]
        let digits = Int(queryItems["digits"] ?? "6") ?? 6
        let period = Int(queryItems["period"] ?? "30") ?? 30
        
        // Если label пустой, используем issuer как fallback
        if label.isEmpty, let issuerValue = issuer {
            label = issuerValue
        }
        
        // Если label все еще пустой, используем "Unknown"
        if label.isEmpty {
            label = "Unknown"
        }
        
        return OTPAuthInfo(
            type: host,
            label: label,
            secret: secret,
            issuer: issuer,
            digits: digits,
            period: period
        )
    }
    
}

enum AddAccountButtons: String, CaseIterable {
    case scan = "QR Scan"
    case photo = "via Photos"
    case manual = "Manually"
    
    var image: Image {
        switch self {
        case .scan: return Image(.scanner)
        case .photo: return Image(.gallery)
        case .manual: return Image(.textSelection)
        }
    }
}
