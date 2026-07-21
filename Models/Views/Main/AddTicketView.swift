import SwiftUI
import CoreData

struct AddTicketView: View {
    @EnvironmentObject var viewModel: AddTicketViewModel

    /// CTA Scanner du HomeView — ouvre l'intro scanner dès l'apparition
    var autoStartScanner: Bool = false

    @State private var showSuccessPopup   = false
    @State private var showErrorPopup     = false
    @State private var showScanFlow       = false
    @State private var showCategoryPicker = false
    @State private var didAutoLaunchScanner = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Background.primary
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Theme.Spacing.xl) {

                        scanButton

                        TicketForm(
                            storeName: $viewModel.storeName,
                            amount: $viewModel.amount,
                            date: $viewModel.date,
                            category: $viewModel.category,
                            description: $viewModel.description,
                            storeConfidence: FieldConfidence(ocr: viewModel.storeConfidence),
                            amountConfidence: FieldConfidence(ocr: viewModel.amountConfidence),
                            dateConfidence: FieldConfidence(ocr: viewModel.dateConfidence),
                            categorySuggested: viewModel.ocrCategorySuggestion != nil,
                            onPickCategory: {
                                Haptic.light()
                                showCategoryPicker = true
                            }
                        )

                        PrimaryButton(title: "Enregistrer", icon: "tray.and.arrow.down.fill") {
                            if viewModel.saveTicket() {
                                Haptic.success()
                                showSuccessPopup = true
                                WidgetSync.updateSnapshot(context: viewModel.context)
                            } else {
                                Haptic.error()
                                showErrorPopup = true
                            }
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.xxl)
                    .padding(.top, Theme.Spacing.l)
                    .padding(.bottom, Theme.Spacing.xl)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("Ajouter un ticket")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Un seul lancement automatique garanti — un retour arrière ou un
                // re-render ne doivent jamais rouvrir le scanner
                guard autoStartScanner, !didAutoLaunchScanner else { return }
                didAutoLaunchScanner = true
                showScanFlow = true
            }

            // UNIQUE modale du flux scanner (Home + AddTicket). Tout le parcours
            // (intro, priming, caméra, traitement, repli) est piloté à l'intérieur
            // par ScannerFlowView via ScannerStep — aucune cover imbriquée.
            .fullScreenCover(isPresented: $showScanFlow) {
                ScannerFlowView { result in
                    viewModel.handleOCRResult(result)
                }
            }

            .sheet(isPresented: $showCategoryPicker, onDismiss: {
                viewModel.ocrCategorySuggestion = nil
            }) {
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

    // MARK: - Scan (action secondaire, DS V2)

    private var scanButton: some View {
        Button {
            Haptic.light()
            showScanFlow = true
        } label: {
            HStack(spacing: Theme.Spacing.s) {
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 20, weight: .semibold))
                Text("Scanner un ticket")
                    .font(Theme.Typography.headline)
            }
            .foregroundColor(Theme.primaryBlue)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Theme.primaryBlue.opacity(0.12))
            .cornerRadius(Theme.Radius.button)
        }
        .buttonStyle(.plain)
    }
}
