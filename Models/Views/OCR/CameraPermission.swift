import SwiftUI
import AVFoundation

struct CameraPermissionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var cameraStatus: AVAuthorizationStatus = .notDetermined

    var body: some View {
        VStack(spacing: 28) {

            // Illustration
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 72))
                .foregroundColor(Color(Theme.primaryBlue))
                .padding(.top, 40)

            Text("Autoriser l’accès à la caméra")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)

            Text("eTix a besoin de votre caméra pour scanner vos tickets et remplir automatiquement les informations.")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()

            Button(action: requestPermission) {
                Text("Continuer")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(Theme.primaryBlue))
                    .foregroundColor(.white)
                    .cornerRadius(14)
            }
            .padding(.horizontal)

            Button("Annuler") {
                dismiss()
            }
            .foregroundColor(.secondary)
            .padding(.bottom, 40)
        }
        .onAppear {
            cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        }
    }

    private func requestPermission() {
        switch cameraStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        goToScanner()
                    }
                }
            }

        case .denied, .restricted:
            openSettings()

        case .authorized:
            goToScanner()

        @unknown default:
            break
        }
    }

    private func goToScanner() {
        // Navigation vers la vue Scanner OCR
        NotificationCenter.default.post(name: .openOCRScanner, object: nil)
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
