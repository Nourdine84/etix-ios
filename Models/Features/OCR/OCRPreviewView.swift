import SwiftUI

struct OCRPreviewView: View {

    @ObservedObject var viewModel: OCRViewModel
    @Environment(\.dismiss) private var dismiss

    // Champs éditables (pré-remplis)
    @State private var storeName: String = ""
    @State private var amount: String = ""
    @State private var date: Date = Date()

    // Callback vers AddTicket
    let onConfirm: (OCRExtractedData) -> Void

    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {

                    // 🖼️ Image scannée
                    if let image = viewModel.capturedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 220)
                            .cornerRadius(14)
                            .shadow(radius: 4)
                    }

                    // 🔍 Confiance OCR
                    confidenceSection

                    // ✏️ Formulaire OCR
                    formSection
                }
                .padding()
            }
            .navigationTitle("Vérifier le ticket")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        Haptic.light()
                        viewModel.reset()
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Confirmer") {
                        confirm()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            preloadData()
        }
    }
}

// MARK: - UI Sections
private extension OCRPreviewView {

    var confidenceSection: some View {
        Group {
            if let confidence = viewModel.extractedData?.confidence {

                let value = confidence   // 🔑 Double garanti ici

                HStack {
                    Image(systemName: confidenceIcon(for: value))
                        .foregroundColor(confidenceColor(for: value))

                    Text(confidenceText(for: value))
                        .font(.caption)
                        .foregroundColor(confidenceColor(for: value))

                    Spacer()
                }
                .padding(10)
                .background(Color(.tertiarySystemGroupedBackground))
                .cornerRadius(10)
            }
        }
    }

    var formSection: some View {
        VStack(alignment: .leading, spacing: 16) {

            Text("Informations détectées")
                .font(.headline)

            TextField("Nom du magasin", text: $storeName)
                .textInputAutocapitalization(.words)

            TextField("Montant (€)", text: $amount)
                .keyboardType(.decimalPad)

            DatePicker(
                "Date",
                selection: $date,
                displayedComponents: .date
            )
        }
        .textFieldStyle(.roundedBorder)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}

// MARK: - Logic
private extension OCRPreviewView {

    func preloadData() {
        guard let data = viewModel.extractedData else { return }

        storeName = data.storeName ?? ""
        amount = data.amount != nil ? String(format: "%.2f", data.amount!) : ""
        date = data.date ?? Date()
    }

    func confirm() {
        Haptic.success()

        let cleanedAmount = Double(
            amount
                .replacingOccurrences(of: ",", with: ".")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        )

        let result = OCRExtractedData(
            storeName: storeName.trimmingCharacters(in: .whitespacesAndNewlines),
            amount: cleanedAmount,
            date: date,
            confidence: viewModel.extractedData?.confidence ?? 0.0
        )

        onConfirm(result)
        viewModel.reset()
        dismiss()
    }
}

// MARK: - Confidence helpers
private extension OCRPreviewView {

    func confidenceText(for value: Double) -> String {
        switch value {
        case 0.8...:
            return "Reconnaissance élevée"
        case 0.5..<0.8:
            return "Reconnaissance moyenne"
        default:
            return "Reconnaissance faible – vérifiez les données"
        }
    }

    func confidenceIcon(for value: Double) -> String {
        switch value {
        case 0.8...:
            return "checkmark.seal.fill"
        case 0.5..<0.8:
            return "exclamationmark.triangle.fill"
        default:
            return "xmark.octagon.fill"
        }
    }

    func confidenceColor(for value: Double) -> Color {
        switch value {
        case 0.8...:
            return .green
        case 0.5..<0.8:
            return .orange
        default:
            return .red
        }
    }
}
