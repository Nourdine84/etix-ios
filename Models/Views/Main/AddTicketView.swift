import SwiftUI
import CoreData

struct AddTicketView: View {
    @EnvironmentObject var viewModel: AddTicketViewModel

    @State private var showSuccessPopup  = false
    @State private var showErrorPopup    = false
    @State private var showPermission    = false
    @State private var showOCRScanner    = false
    @State private var showCategoryPicker = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // MARK: Scan OCR
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
                        .background(Theme.primaryBlue.opacity(0.12))
                        .foregroundColor(Theme.primaryBlue)
                        .cornerRadius(14)
                    }
                    .padding(.horizontal)

                    // MARK: Form Card
                    VStack(alignment: .leading, spacing: 16) {

                        Text("Informations du ticket")
                            .font(.headline)
                            .padding(.bottom, 4)

                        Group {
                            TextField("Nom du magasin", text: $viewModel.storeName)
                                .textInputAutocapitalization(.words)
                                .textFieldStyle(.roundedBorder)

                            TextField("Montant (€)", text: $viewModel.amount)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)

                            DatePicker("Date",
                                       selection: $viewModel.date,
                                       displayedComponents: .date)
                        }

                        // Category picker row
                        Button {
                            Haptic.light()
                            showCategoryPicker = true
                        } label: {
                            HStack {
                                Text(viewModel.category.isEmpty ? "Catégorie" : viewModel.category)
                                    .foregroundColor(
                                        viewModel.category.isEmpty
                                        ? Color(.placeholderText)
                                        : .primary
                                    )
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 8)
                            .frame(height: 34)
                            .background(Color(.systemBackground))
                            .cornerRadius(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color(.separator), lineWidth: 0.5)
                            )
                        }
                        .buttonStyle(.plain)

                        TextField("Description (optionnel)", text: $viewModel.description)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.08), radius: 5, y: 2)
                    .padding(.horizontal)

                    // MARK: Save
                    eTixButton(title: "Enregistrer", icon: "tray.and.arrow.down.fill") {
                        if viewModel.saveTicket() {
                            Haptic.success()
                            showSuccessPopup = true
                            WidgetSync.updateSnapshot(context: viewModel.context)
                            print("🧪 Widget monthTotal:",
                                  UserDefaults(suiteName: "group.etix.shared")?.double(forKey: "monthTotal") ?? -1)
                        } else {
                            Haptic.error()
                            showErrorPopup = true
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Ajouter un ticket")

            // MARK: OCR listeners
            .onReceive(NotificationCenter.default.publisher(for: .openOCRScanner)) { _ in
                showOCRScanner = true
            }
            .onReceive(NotificationCenter.default.publisher(for: .openCameraPermission)) { _ in
                showPermission = true
            }

            // MARK: Sheets
            .sheet(isPresented: $showPermission) {
                CameraPermissionView()
            }
            .sheet(isPresented: $showOCRScanner) {
                OCRScannerView { result in
                    viewModel.handleOCRResult(result)
                }
            }
            .sheet(isPresented: $showCategoryPicker) {
                CategoryPickerSheet(
                    selectedCategory: $viewModel.category,
                    context: viewModel.context
                )
            }
        }
        // MARK: Popups
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
}
