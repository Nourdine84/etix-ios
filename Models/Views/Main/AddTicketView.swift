import SwiftUI
import CoreData
import UIKit

struct AddTicketView: View {

    // MARK: - Dependencies
    @EnvironmentObject var viewModel: AddTicketViewModel
    @StateObject private var ocrVM = OCRViewModel()

    // MARK: - UI State
    @State private var showSuccessPopup = false
    @State private var showErrorPopup = false

    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {

                    // 📷 OCR
                    scanButton

                    // 🧾 Formulaire
                    ticketForm

                    // 💾 Save
                    saveButton
                }
                .padding(.top)
            }
            .navigationTitle("Ajouter un ticket")
        }

        // 📸 Scanner caméra
        .sheet(isPresented: $ocrVM.showScanner) {
            OCRScannerView(
                onImageCaptured: { image in
                    ocrVM.handleCapturedImage(image)
                },
                onCancel: {
                    ocrVM.closeScanner()
                }
            )
        }
    }
}

// MARK: - Subviews
private extension AddTicketView {

    var scanButton: some View {
        Button {
            Haptic.light()
            if ocrVM.permissionState == .authorized {
                ocrVM.openScanner()
            } else {
                ocrVM.requestPermission()
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 22, weight: .bold))
                Text("Scanner un ticket")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(Theme.primaryBlue).opacity(0.12))
            .foregroundColor(Color(Theme.primaryBlue))
            .cornerRadius(14)
        }
        .padding(.horizontal)
    }

    var ticketForm: some View {
        VStack(alignment: .leading, spacing: 16) {

            Text("Informations du ticket")
                .font(.headline)

            TextField("Nom du magasin", text: $viewModel.storeName)
                .textInputAutocapitalization(.words)
                .textFieldStyle(.roundedBorder)

            TextField("Montant (€)", text: $viewModel.amount)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)

            DatePicker(
                "Date",
                selection: $viewModel.date,
                displayedComponents: .date
            )

            TextField("Catégorie", text: $viewModel.category)
                .textFieldStyle(.roundedBorder)

            TextField("Description (optionnel)", text: $viewModel.description)
                .textFieldStyle(.roundedBorder)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 5, y: 2)
        .padding(.horizontal)
    }

    var saveButton: some View {
        eTixButton(
            title: "Enregistrer",
            icon: "tray.and.arrow.down.fill"
        ) {
            handleSave()
        }
        .padding(.horizontal)
    }
}

// MARK: - Actions
private extension AddTicketView {

    func handleSave() {
        if viewModel.saveTicket() {
            Haptic.success()
            showSuccessPopup = true
            // WidgetSync.updateSnapshot(context: viewModel.context) // volontairement désactivé
        } else {
            Haptic.error()
            showErrorPopup = true
        }
    }

    // ✅ Injection OCR → formulaire
    func injectOCR(_ result: OCRExtractedData) {
        if let store = result.storeName {
            viewModel.storeName = store
        }
        if let amount = result.amount {
            viewModel.amount = String(format: "%.2f", amount)
        }
        if let date = result.date {
            viewModel.date = date
        }
    }

    // 🧠 Décision auto-validation OCR (FIX FINAL)
    func shouldAutoAcceptOCR(_ data: OCRExtractedData) -> Bool {
        return
            data.confidence >= 0.8 &&
            data.storeName != nil &&
            data.amount != nil
    }
}
