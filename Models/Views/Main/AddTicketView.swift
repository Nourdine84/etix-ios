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

                    // 🔵 Bouton SCAN OCR
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

                    // 🔶 Carte principale
                    VStack(alignment: .leading, spacing: 16) {

                        Text("Informations du ticket")
                            .font(.headline)
                            .padding(.bottom, 4)

                        Group {

                            // Magasin
                            TextField("Nom du magasin", text: $viewModel.storeName)
                                .textInputAutocapitalization(.words)

                            // Montant
                            TextField("Montant (€)", text: $viewModel.amount)
                                .keyboardType(.decimalPad)

                            // Date
                            DatePicker(
                                "Date",
                                selection: $viewModel.date,
                                displayedComponents: .date
                            )

                            // ✅ Catégorie réelle (Picker normalisé)
                            Picker("Catégorie", selection: $viewModel.category) {
                                ForEach(TicketCategory.allCases) { category in
                                    Text(category.rawValue)
                                        .tag(category)
                                }
                            }
                            .pickerStyle(.menu)

                            // Description
                            TextField(
                                "Description (optionnel)",
                                text: $viewModel.description
                            )
                        }
                        .textFieldStyle(.roundedBorder)
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.08), radius: 5, y: 2)
                    .padding(.horizontal)

                    // 🔵 Enregistrer
                    eTixButton(
                        title: "Enregistrer",
                        icon: "tray.and.arrow.down.fill"
                    ) {
                        if viewModel.saveTicket() {
                            Haptic.success()
                            showSuccessPopup = true

                            // 🔥 Mise à jour widget
                            WidgetSync.updateSnapshot(
                                context: viewModel.context
                            )
                        } else {
                            Haptic.error()
                            showErrorPopup = true
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }
            .navigationTitle("Ajouter un ticket")

            // MARK: - OCR listeners
            .onReceive(
                NotificationCenter.default.publisher(
                    for: .openOCRScanner
                )
            ) { _ in
                showOCRScanner = true
            }

            .onReceive(
                NotificationCenter.default.publisher(
                    for: .openCameraPermission
                )
            ) { _ in
                showPermission = true
            }

            // MARK: - OCR Sheets
            .sheet(isPresented: $showPermission) {
                CameraPermissionView()
            }

            .sheet(isPresented: $showOCRScanner) {
                OCRScannerView { result in
                    handleOCRResult(result)
                }
            }
        }

        // MARK: - Popups custom
        .overlay {
            if showSuccessPopup {
                SuccessPopup(
                    title: "Ticket enregistré ✅",
                    message: "Ton ticket a bien été ajouté."
                ) {
                    showSuccessPopup = false
                }
                .zIndex(10)
            }

            if showErrorPopup {
                ErrorPopup(
                    message: "Impossible d'enregistrer. Vérifie le magasin et le montant."
                ) {
                    showErrorPopup = false
                }
                .zIndex(10)
            }
        }
    }

    // MARK: - OCR → Pré-remplissage
    private func handleOCRResult(_ result: OCRExtractedData) {
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
