import SwiftUI
import AVFoundation

/// Écran d'introduction premium avant l'ouverture du scanner système.
///
/// Réconcilie la maquette V2 (badge, cadre, guidage) avec la réalité technique :
/// la **capture reste faite par `VNDocumentCameraViewController`** (ADR-0004,
/// Option C). Cet écran centralise la demande de permission caméra et constitue
/// le point d'entrée **unique** du scan (depuis Home comme depuis AddTicket).
///
/// Étape 5 : l'orchestration (traitement OCR, succès, machine à états) viendra
/// s'appuyer sur ce point d'entrée.
struct ScannerIntroView: View {

    /// Appelé avec le résultat OCR une fois un ticket scanné.
    let onScanned: (OCRExtractedData) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
    @State private var showScanner = false
    @State private var showDeniedAlert = false

    var body: some View {
        ZStack {
            Theme.Background.primary
                .ignoresSafeArea()

            VStack(spacing: Theme.Spacing.xl) {
                Spacer(minLength: 0)

                EtixBadge(size: 64)

                scannerFrame

                VStack(spacing: Theme.Spacing.s) {
                    Text("Scanner un ticket")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text("Positionne ton ticket dans le cadre.\neTix lit le magasin, le montant et la date.")
                        .font(Theme.Typography.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                Spacer(minLength: 0)

                PrimaryButton(title: "Scanner", icon: "camera.viewfinder") {
                    startScan()
                }

                Button("Annuler") {
                    dismiss()
                }
                .font(Theme.Typography.subheadline)
                .foregroundColor(.secondary)
            }
            .padding(.horizontal, Theme.Spacing.xxl)
            .padding(.vertical, Theme.Spacing.section)
        }
        .fullScreenCover(isPresented: $showScanner) {
            OCRScannerView(
                onScanResult: { result in
                    onScanned(result)
                    dismiss()
                },
                onCancel: {
                    // Retour propre à l'intro (l'utilisateur peut réessayer).
                    showScanner = false
                }
            )
            .ignoresSafeArea()
        }
        .alert("Accès caméra requis", isPresented: $showDeniedAlert) {
            Button("Réglages") { openSettings() }
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("Autorise l'accès à la caméra dans les Réglages pour scanner tes tickets.")
        }
    }

    // MARK: - Cadre illustratif (style maquette, sans caméra live)

    private var scannerFrame: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Theme.Radius.xl, style: .continuous)
                .strokeBorder(
                    Theme.primaryBlue.opacity(0.5),
                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                )
            Image(systemName: "doc.text.viewfinder")
                .font(.system(size: 72, weight: .light))
                .foregroundColor(Theme.primaryBlue.opacity(0.7))
        }
        .frame(width: 210, height: 250)
    }

    // MARK: - Permission caméra (centralisée ici)

    private func startScan() {
        switch cameraStatus {
        case .authorized:
            showScanner = true

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
                    if granted { showScanner = true }
                }
            }

        case .denied, .restricted:
            showDeniedAlert = true

        @unknown default:
            break
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
