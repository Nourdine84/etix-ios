import SwiftUI
import AVFoundation

/// Point d'entrée **unique** du scan et orchestrateur de son flux.
///
/// Réconcilie la maquette V2 (badge, cadre, guidage) avec la réalité technique :
/// la capture reste faite par `VNDocumentCameraViewController` (ADR-0004,
/// Option C). Enchaîne : intro → capture → **traitement OCR hors main thread**
/// (écran dédié) → livraison du résultat, ou repli « rien détecté ».
/// Centralise aussi la permission caméra.
struct ScannerIntroView: View {

    /// Appelé avec le résultat OCR une fois un ticket lu avec succès.
    let onScanned: (OCRExtractedData) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
    @State private var isScanning = false      // caméra système présentée
    @State private var isProcessing = false    // reconnaissance OCR en cours
    @State private var showNotFound = false     // aucun champ détecté
    @State private var showDeniedAlert = false

    var body: some View {
        ZStack {
            Theme.Background.primary
                .ignoresSafeArea()

            if isProcessing {
                OCRProcessingView()
            } else if showNotFound {
                notFoundView
            } else {
                introContent
            }
        }
        .fullScreenCover(isPresented: $isScanning) {
            OCRScannerView(
                onCaptured: { image in handleCapture(image) },
                onCancel: {
                    // Retour propre à l'intro — rien ne reste bloqué.
                    isProcessing = false
                    showNotFound = false
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

    // MARK: - Intro

    private var introContent: some View {
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

    // MARK: - Repli « rien détecté »

    private var notFoundView: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Spacer(minLength: 0)

            Image(systemName: "doc.questionmark")
                .font(.system(size: 56, weight: .light))
                .foregroundColor(.secondary)

            VStack(spacing: Theme.Spacing.s) {
                Text("Aucune information détectée")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                Text("Le ticket n'a pas pu être lu. Réessaie en cadrant mieux, ou saisis les informations manuellement.")
                    .font(Theme.Typography.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer(minLength: 0)

            PrimaryButton(title: "Réessayer", icon: "arrow.clockwise") {
                showNotFound = false
                startScan()
            }

            Button("Saisir manuellement") {
                dismiss()
            }
            .font(Theme.Typography.subheadline)
            .foregroundColor(.secondary)
        }
        .padding(.horizontal, Theme.Spacing.xxl)
        .padding(.vertical, Theme.Spacing.section)
    }

    // MARK: - Flux

    private func handleCapture(_ image: UIImage) {
        isProcessing = true
        TextRecognizer.recognize(image) { text in
            let result = ReceiptParser.parse(text)
            isProcessing = false
            if result.isEmpty {
                showNotFound = true
            } else {
                onScanned(result)
                dismiss()
            }
        }
    }

    // MARK: - Permission caméra (centralisée ici)

    private func startScan() {
        switch cameraStatus {
        case .authorized:
            isScanning = true

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
                    if granted { isScanning = true }
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
