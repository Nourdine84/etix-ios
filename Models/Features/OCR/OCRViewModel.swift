import Foundation
import AVFoundation
import SwiftUI
import UIKit

final class OCRViewModel: ObservableObject {

    // MARK: - Permission caméra
    enum CameraPermissionState {
        case unknown
        case denied
        case authorized
    }

    @Published var permissionState: CameraPermissionState = .unknown

    // MARK: - Scanner
    @Published var showScanner: Bool = false
    @Published var capturedImage: UIImage? = nil

    // Résultat OCR
    @Published var extractedData: OCRExtractedData? = nil

    // MARK: - Init
    init() {
        checkPermission()
    }

    // MARK: - Permissions caméra
    func checkPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        DispatchQueue.main.async {
            switch status {
            case .authorized:
                self.permissionState = .authorized
            case .denied, .restricted:
                self.permissionState = .denied
            case .notDetermined:
                self.permissionState = .unknown
            @unknown default:
                self.permissionState = .denied
            }
        }
    }

    func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                self.permissionState = granted ? .authorized : .denied
                if granted {
                    self.showScanner = true
                }
            }
        }
    }

    // MARK: - Scanner control
    func openScanner() {
        if permissionState == .authorized {
            showScanner = true
        }
    }

    func closeScanner() {
        showScanner = false
    }

    // MARK: - Image capturée → OCR (VISION)
    func handleCapturedImage(_ image: UIImage) {
        capturedImage = image
        showScanner = false

        OCRTextRecognizer.recognizeText(from: image) { [weak self] data in
            DispatchQueue.main.async {
                self?.extractedData = data
            }
        }
    }
    // MARK: - Reset (utile plus tard)
    func reset() {
        capturedImage = nil
        extractedData = nil
        showScanner = false
    }
}

