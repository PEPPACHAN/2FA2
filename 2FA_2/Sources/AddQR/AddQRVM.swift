//
//  AddQRVM.swift
//  2FA_2
//
//  Created by PEPPA CHAN on 20.11.2025.
//


import SwiftUI
import AVFoundation
import UIKit


final class AddQRVM {
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


// MARK: - UIViewController, который запускает AVCapture и сканирует QR
final class QRScannerViewController: UIViewController {
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var onFound: ((String) -> Void)?

    private var isScanning = true

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupSession()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    deinit {
        stopSession()
    }

    // MARK: - Setup Capture
    private func setupSession() {
        // Проверяем доступность камеры
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.configureSession()
                    } else {
                        self.showPermissionDenied()
                    }
                }
            }
        default:
            showPermissionDenied()
        }
    }

    private func configureSession() {
        let session = AVCaptureSession()
        session.sessionPreset = .high

        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else {
            showConfigurationError()
            return
        }

        if session.canAddInput(input) {
            session.addInput(input)
        } else {
            showConfigurationError()
            return
        }

        let output = AVCaptureMetadataOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            output.metadataObjectTypes = [.qr] // только QR; можно добавить .ean13 etc.
        } else {
            showConfigurationError()
            return
        }

        // Preview layer
        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        preview.frame = view.layer.bounds
        view.layer.insertSublayer(preview, at: 0)

        self.captureSession = session
        self.previewLayer = preview

        startSession()
    }

    private func startSession() {
        guard let session = captureSession, !session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }
    }

    private func stopSession() {
        guard let session = captureSession, session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            session.stopRunning()
        }
    }

    // MARK: - Error / Permission UI helpers
    private func showPermissionDenied() {
        // простой placeholder: можно заменить красивым UI
        let label = UILabel()
        label.text = "Нет доступа к камере. Включите в настройках."
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func showConfigurationError() {
        let label = UILabel()
        label.text = "Не удалось инициализировать камеру"
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: - AVMetadata Delegate
extension QRScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard isScanning else { return } // предотвращаем повторные вызовы
        for metadata in metadataObjects {
            if let readable = metadata as? AVMetadataMachineReadableCodeObject,
               readable.type == .qr,
               let string = readable.stringValue,
               !string.isEmpty {
                isScanning = false
                // feedback
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                // остановим сессию и отдадим результат
                stopSession()
                onFound?(string)
                break
            }
        }
    }
}

// MARK: - SwiftUI wrapper
struct QRScannerView: UIViewControllerRepresentable {
    /// Вызывается при найденном коде
    var onFound: (String) -> Void

    func makeUIViewController(context: Context) -> QRScannerViewController {
        let vc = QRScannerViewController()
        vc.onFound = { code in
            // пробрасываем в SwiftUI
            DispatchQueue.main.async {
                onFound(code)
            }
        }
        return vc
    }

    func updateUIViewController(_ uiViewController: QRScannerViewController, context: Context) {
        // ничего не делаем — контроллер сам держит сессию
    }

    static func dismantleUIViewController(_ uiViewController: QRScannerViewController, coordinator: ()) {
        uiViewController.captureSession?.stopRunning()
    }
}
