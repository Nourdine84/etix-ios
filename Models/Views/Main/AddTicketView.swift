import SwiftUI
import CoreData

struct AddTicketView: View {

    @EnvironmentObject var viewModel: AddTicketViewModel

    // MARK: - UI State
    @State private var showSuccessPopup = false
    @State private var showErrorPopup = false

    // OCR (préservé pour V2, non utilisé pour l’instant)
    @State private var showPermission = false
    @State private var showOCRScanner = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {

                    scanButton

                    ticketForm

                    saveButton
                }
                .padding(.top)
            }
            .navigationTitle("Ajouter un ticket")
        }
    }
}

// MARK: - Subviews
private extension AddTicketView {

    var scanButton: some View {
        Button {
            Haptic.light()
            NotificationCenter.default.post(name: .openCameraPermission, object: nil)
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

            Group {
                TextField("Nom du magasin", text: $viewModel.storeName)
                    .textInputAutocapitalization(.words)

                TextField("Montant (€)", text: $viewModel.amount)
                    .keyboardType(.decimalPad)

                DatePicker(
                    "Date",
                    selection: $viewModel.date,
                    displayedComponents: .date
                )

                TextField("Catégorie", text: $viewModel.category)

                TextField("Description (optionnel)", text: $viewModel.description)
            }
            .textFieldStyle(.roundedBorder)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 5, y: 2)
        .padding(.horizontal)
    }

    var saveButton: some View {
        eTixButton(title: "Enregistrer", icon: "tray.and.arrow.down.fill") {
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
            WidgetSync.updateSnapshot(context: viewModel.context)
        } else {
            Haptic.error()
            showErrorPopup = true
        }
    }

    func handleOCRResult(_ result: OCRExtractedData) {
        if let store = result.storeName { viewModel.storeName = store }
        if let amount = result.amount { viewModel.amount = String(amount) }
        if let date = result.date { viewModel.date = date }
    }
}
