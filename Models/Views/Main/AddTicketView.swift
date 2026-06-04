import SwiftUI
import CoreData

struct AddTicketView: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: AddTicketViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.selectedTabBinding) private var selectedTab

    @State private var showDatePicker = false
    @State private var showOCR = false
    @State private var isPressed = false

    private let categories = [
        "Alimentation",
        "Transport",
        "Loisir",
        "Santé",
        "Shopping",
        "Autre"
    ]

    var body: some View {
        NavigationStack {
            ZStack {

                DesignSystem.premiumBackground(for: colorScheme)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: DesignSystem.verticalSpacing) {

                        headerSection
                        formSection
                        saveButton
                    }
                    .padding(.horizontal, DesignSystem.horizontalPadding)
                    .padding(.vertical)
                }
            }
            .navigationTitle("Ajouter un ticket")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showOCR = true
                    } label: {
                        Image(systemName: "camera.viewfinder")
                            .foregroundColor(Theme.primaryBlue)
                    }
                }
            }
            .sheet(isPresented: $showOCR) {
                OCRScannerView { result in
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
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {

            Text("Nouveau ticket")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("Ajoutez une nouvelle dépense")
                .font(.title3.weight(.semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Form

    private var formSection: some View {

        VStack(spacing: DesignSystem.innerSpacing) {

            inputField(title: "Magasin", text: $viewModel.storeName)

            inputField(title: "Montant (€)",
                       text: $viewModel.amount,
                       keyboard: .decimalPad)

            VStack(alignment: .leading, spacing: 8) {
                Text("Catégorie")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Picker("Catégorie", selection: $viewModel.category) {
                    ForEach(categories, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.menu)
            }
            .premiumCard()

            VStack(alignment: .leading, spacing: 8) {
                Text("Date")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    showDatePicker.toggle()
                } label: {
                    HStack {
                        Text(viewModel.date.formatted(date: .long, time: .omitted))
                        Spacer()
                        Image(systemName: "calendar")
                    }
                }
            }
            .premiumCard()

            if showDatePicker {
                DatePicker("",
                           selection: $viewModel.date,
                           displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .premiumCard()
            }

            inputField(title: "Description (optionnel)",
                       text: $viewModel.description)
        }
    }

    private func inputField(
        title: String,
        text: Binding<String>,
        keyboard: UIKeyboardType = .default
    ) -> some View {

        VStack(alignment: .leading, spacing: 8) {

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            TextField("", text: text)
                .keyboardType(keyboard)
        }
        .premiumCard()
    }

    // MARK: - Save Button Premium

    private var saveButton: some View {

        Button {

            let success = viewModel.saveTicket()

            if success {
                UINotificationFeedbackGenerator().notificationOccurred(.success)

                dismiss()

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    selectedTab?.wrappedValue = 2
                }

            } else {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }

        } label: {
            Text("Enregistrer")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.largeRadius)
                        .fill(
                            viewModel.storeName.isEmpty || viewModel.amount.isEmpty
                            ? Theme.primaryBlue.opacity(0.6)
                            : Theme.primaryBlue
                        )
                )
        }
        .scaleEffect(isPressed ? 0.98 : 1)
        .animation(.easeOut(duration: 0.15), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .disabled(viewModel.storeName.isEmpty || viewModel.amount.isEmpty)
        .padding(.top, 10)
    }
}
