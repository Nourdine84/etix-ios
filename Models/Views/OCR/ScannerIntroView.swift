import SwiftUI
import AVFoundation

/// Point d'entrée **unique** du scan et orchestrateur de son flux.
///
/// Réconcilie la maquette V2 (badge, cadre avec ticket + coins, guidage) avec la
/// réalité technique : la capture reste faite par `VNDocumentCameraViewController`
/// (ADR-0004, Option C). Enchaîne : intro → (priming caméra si 1er accès) →
/// capture → **traitement OCR hors main thread** → livraison, ou repli
/// « rien détecté ». Le cadre est une **illustration statique** (aucun aperçu
/// caméra custom).
struct ScannerIntroView: View {

    /// Appelé avec le résultat OCR une fois un ticket lu avec succès.
    let onScanned: (OCRExtractedData) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
    @State private var isScanning = false      // caméra système présentée
    @State private var isProcessing = false    // reconnaissance OCR en cours
    @State private var showNotFound = false     // aucun champ détecté
    @State private var showPriming = false      // écran de priming caméra
    @State private var showDeniedAlert = false

    var body: some View {
        ZStack {
            Theme.Background.primary
                .ignoresSafeArea()

            if isProcessing {
                OCRProcessingView()
            } else if showNotFound {
                notFoundView
            } else if showPriming {
                CameraPrimingView(
                    onAllow: { requestAccessAndScan() },
                    onRefuse: { showPriming = false }
                )
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
                    .font(.system(.title2, design: .rounded).weight(.bold))
                    .foregroundColor(.primary)
                Text("Positionne ton ticket dans le cadre pour le scanner.")
                    .font(.subheadline)
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
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .padding(.horizontal, Theme.Spacing.xxl)
        .padding(.vertical, Theme.Spacing.section)
    }

    /// Cadre statique conforme à la maquette : illustration de ticket + coins
    /// d'accroche. Ce n'est PAS un aperçu caméra (Option C).
    private var scannerFrame: some View {
        receiptIllustration
            .frame(width: 200, height: 250)
            .overlay(
                CornerBrackets(length: 30)
                    .stroke(
                        Theme.primaryBlue.opacity(0.75),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
            )
    }

    private var receiptIllustration: some View {
        VStack(alignment: .leading, spacing: 7) {
            Circle()
                .fill(Theme.primaryBlue.opacity(0.25))
                .frame(width: 22, height: 22)
            receiptLine(0.55)
            Spacer().frame(height: 2)
            receiptLine(0.9)
            receiptLine(0.8)
            receiptLine(0.7)
            Spacer(minLength: 4)
            HStack {
                receiptLine(0.30)
                Spacer()
                receiptLine(0.22)
            }
        }
        .padding(14)
        .frame(width: 150, height: 185)
        .background(Color.white)
        .cornerRadius(Theme.Radius.m)
        .shadow(color: .black.opacity(0.12), radius: 8, y: 3)
    }

    private func receiptLine(_ fraction: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(Color.gray.opacity(0.35))
            .frame(width: 122 * fraction, height: 5)
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
                    .font(.system(.title3, design: .rounded).weight(.semibold))
                    .foregroundColor(.primary)
                Text("Le ticket n'a pas pu être lu. Réessaie en cadrant mieux, ou saisis les informations manuellement.")
                    .font(.subheadline)
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
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .padding(.horizontal, Theme.Spacing.xxl)
        .padding(.vertical, Theme.Spacing.section)
    }

    // MARK: - Flux OCR (inchangé — aucun changement d'architecture)

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
            // Priming premium AVANT la boîte de dialogue système.
            showPriming = true

        case .denied, .restricted:
            showDeniedAlert = true

        @unknown default:
            break
        }
    }

    /// Déclenché par « Autoriser » du priming : demande la permission système,
    /// puis ouvre la caméra si accordée.
    private func requestAccessAndScan() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
                showPriming = false
                if granted { isScanning = true }
            }
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Coins d'accroche

/// Quatre coins d'accroche dessinés autour du cadre scanner (style maquette).
private struct CornerBrackets: Shape {
    var length: CGFloat = 30

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let l = length

        // Haut-gauche
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + l))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX + l, y: rect.minY))

        // Haut-droite
        path.move(to: CGPoint(x: rect.maxX - l, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + l))

        // Bas-droite
        path.move(to: CGPoint(x: rect.maxX, y: rect.maxY - l))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX - l, y: rect.maxY))

        // Bas-gauche
        path.move(to: CGPoint(x: rect.minX + l, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - l))

        return path
    }
}
