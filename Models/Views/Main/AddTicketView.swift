import SwiftUI
import CoreData

struct AddTicketView: View {

    @EnvironmentObject var viewModel: AddTicketViewModel

    // MARK: - Popups
    @State private var showSuccessPopup = false
    @State private var showErrorPopup = false

    // MARK: - OCR
    @State private var showPermission = false
    @State private var showOCRScanner = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    scanButton
                    ticketFormCard
                    saveButton
                }
                .padding(.top)
            }
            .navigationTitle("Ajouter un ticket")
            .ocrListeners(
                showPermission: $showPermission,
                showOCRScanner: $showOCRScanner,
                onResult: handleOCRResult
            )
        }
        .popupOverlay(
            success: $showSuccessPopup,
            error: $showErrorPopup
        )
    }
}

// MARK: - Subviews
private extension AddTicketView {

    // 🔵 Bouton OCR
    var scanButton: some View {
        Button {
            Haptic.light()
            NotificationCenter.default.post(
                name: .openCameraPermission,
                object: nil
            )
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

    // 🔶 Carte formulaire
    var ticketFormCard: some View {
        VStack(alignment: .leading, spacing: 16) {

            Text("Informations du ticket")
                .font(.headline)

            TextField("Nom du magasin", text: $viewModel.storeName)
                .textInputAutocapitalization(.words)

            TextField("Montant (€)", text: $viewModel.amount)
                .keyboardType(.decimalPad)

            DatePicker(
                "Date",
                selection: $viewModel.date,
                displayedComponents: .date
            )

            // ✅ Picker Catégorie normalisé
            Picker("Catégorie", selection: $viewModel.category) {
                ForEach(TicketCategory.allCases, id: \.self) { category in
                    Text(category.rawValue)
                        .tag(category)
                }
            }
            .pickerStyle(.menu)

            TextField(
                "Description (optionnel)",
                text: $viewModel.description
            )
        }
        .textFieldStyle(.roundedBorder)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 5, y: 2)
        .padding(.horizontal)
    }

    // 💾 Bouton Enregistrer
    var saveButton: some View {
        eTixButton(
            title: "Enregistrer",
            icon: "tray.and.arrow.down.fill"
        ) {
            if viewModel.saveTicket() {

                Haptic.success()
                showSuccessPopup = true

                // 🔁 Refresh Widget
                WidgetSync.updateSnapshot(
                    context: viewModel.context
                )

                // 🔁 EVENT MÉTIER → navigation + refresh KPI
                NotificationCenter.default.post(
                    name: .ticketAdded,
                    object: nil
                )

            } else {
                Haptic.error()
                showErrorPopup = true
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - OCR Handling
private extension AddTicketView {

    func handleOCRResult(_ result: OCRExtractedData) {
        if let store = result.storeName {
            viewModel.storeName = store
        }
        if let amount = result.amount {
            viewModel.amount = String(amount)
        }
        if let date = result.date {
            viewModel.date = date
        }
    }
}

// MARK: - View Extensions
private extension View {

    // 📷 OCR listeners
    func ocrListeners(
        showPermission: Binding<Bool>,
        showOCRScanner: Binding<Bool>,
        onResult: @escaping (OCRExtractedData) -> Void
    ) -> some View {
        self
            .onReceive(
                NotificationCenter.default.publisher(for: .openOCRScanner)
            ) { _ in
                showOCRScanner.wrappedValue = true
            }
            .onReceive(
                NotificationCenter.default.publisher(for: .openCameraPermission)
            ) { _ in
                showPermission.wrappedValue = true
            }
            .sheet(isPresented: showPermission) {
                CameraPermissionView()
            }
            .sheet(isPresented: showOCRScanner) {
                OCRScannerView { result in
                    onResult(result)
                }
            }
    }

    // ✅ Popups custom
    func popupOverlay(
        success: Binding<Bool>,
        error: Binding<Bool>
    ) -> some View {
        self.overlay {
            if success.wrappedValue {
                SuccessPopup(
                    title: "Ticket enregistré ✅",
                    message: "Ton ticket a bien été ajouté."
                ) {
                    success.wrappedValue = false
                }
                .zIndex(10)
            }

            if error.wrappedValue {
                ErrorPopup(
                    message: "Impossible d'enregistrer. Vérifie le magasin et le montant."
                ) {
                    error.wrappedValue = false
                }
                .zIndex(10)
            }
        }
    }
}
