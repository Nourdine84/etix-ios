import SwiftUI
import CoreData
import UIKit

struct AddTicketView: View {

    // MARK: - Dependencies
    @EnvironmentObject var viewModel: AddTicketViewModel
    @FocusState private var focusedField: Field?

    // MARK: - UI State
    @State private var showSuccessPopup = false
    @State private var showErrorPopup = false

    // MARK: - Form validation
    private var isFormValid: Bool {
        !viewModel.storeName
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
        &&
        Double(
            viewModel.amount
                .replacingOccurrences(of: ",", with: ".")
        ) != nil
    }

    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 22) {

                    // 📷 OCR (désactivé en V2)
                    scanButtonDisabled

                    // 🧾 Formulaire
                    ticketForm

                    // 💾 Save
                    saveButton
                }
                .padding(.top)
            }
            .navigationTitle("Ajouter un ticket")
        }
        // 🔽 Ferme le clavier si tap en dehors
        .onTapGesture {
            hideKeyboard()
        }
        // 🎯 Focus auto sur le premier champ
        .onAppear {
            focusedField = .store
        }
    }
}

// MARK: - Subviews
private extension AddTicketView {

    var scanButtonDisabled: some View {
        HStack(spacing: 12) {
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 22, weight: .bold))

            Text("Scanner un ticket (bientôt)")
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.12))
        .foregroundColor(.gray)
        .cornerRadius(14)
        .padding(.horizontal)
    }

    var ticketForm: some View {
        VStack(alignment: .leading, spacing: 16) {

            Text("Informations du ticket")
                .font(.headline)

            // 🏪 Magasin
            TextField("Nom du magasin", text: $viewModel.storeName)
                .textInputAutocapitalization(.words)
                .textFieldStyle(.roundedBorder)
                .focused($focusedField, equals: .store)
                .submitLabel(.next)
                .onSubmit {
                    focusedField = .amount
                }

            // 💰 Montant
            TextField("Montant (€)", text: $viewModel.amount)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
                .focused($focusedField, equals: .amount)
                .submitLabel(.done)
                .onSubmit {
                    hideKeyboard()
                }
                .onChange(of: viewModel.amount) { newValue in
                    // Normalisation virgule → point
                    viewModel.amount = newValue
                        .replacingOccurrences(of: ",", with: ".")
                }

            // 📅 Date
            DatePicker(
                "Date",
                selection: $viewModel.date,
                displayedComponents: .date
            )

            // 🏷️ Catégorie
            TextField("Catégorie", text: $viewModel.category)
                .textFieldStyle(.roundedBorder)

            // 📝 Description
            TextField("Description (optionnel)", text: $viewModel.description)
                .textFieldStyle(.roundedBorder)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(
            color: .black.opacity(0.08),
            radius: 5,
            y: 2
        )
        .padding(.horizontal)
    }

    var saveButton: some View {
        eTixButton(
            title: "Enregistrer",
            icon: "tray.and.arrow.down.fill",
            disabled: !isFormValid
        ) {
            handleSave()
        }
        .padding(.horizontal)
        .opacity(isFormValid ? 1 : 0.5)
        .animation(.easeInOut(duration: 0.2), value: isFormValid)
    }
}

// MARK: - Actions
private extension AddTicketView {

    func handleSave() {
        hideKeyboard()

        if viewModel.saveTicket() {
            Haptic.success()
            showSuccessPopup = true
        } else {
            Haptic.error()
            showErrorPopup = true
        }
    }

    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

// MARK: - Focus enum
private extension AddTicketView {
    enum Field {
        case store
        case amount
    }
}
