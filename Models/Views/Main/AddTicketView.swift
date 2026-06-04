import SwiftUI
import CoreData

struct AddTicketView: View {

    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var storeName: String = ""
    @State private var amount: String = ""
    @State private var category: String = "Alimentation"
    @State private var selectedDate: Date = Date()
    @State private var description: String = ""

    @State private var showDatePicker = false

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

                DesignSystem.premiumBackground
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
            // 🔵 Stabilisation iOS 17+
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(.systemBackground), for: .navigationBar)
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

            inputField(title: "Magasin",
                       text: $storeName)

            inputField(title: "Montant (€)",
                       text: $amount,
                       keyboard: .decimalPad)

            VStack(alignment: .leading, spacing: 8) {

                Text("Catégorie")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Picker("Catégorie", selection: $category) {
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
                        Text(DateFormatter.localizedString(
                            from: selectedDate,
                            dateStyle: .medium,
                            timeStyle: .none
                        ))
                        Spacer()
                        Image(systemName: "calendar")
                    }
                }
            }
            .premiumCard()

            if showDatePicker {
                DatePicker("",
                           selection: $selectedDate,
                           displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .premiumCard()
            }

            inputField(title: "Description (optionnel)",
                       text: $description)
        }
    }

    // MARK: - Input Field

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

    // MARK: - Save Button

    private var saveButton: some View {

        Button {
            // 🔵 Haptic immédiat
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            saveTicket()
        } label: {
            Text("Enregistrer")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.largeRadius)
                        .fill(
                            storeName.isEmpty || amount.isEmpty
                            ? Theme.primaryBlue.opacity(0.6)
                            : Theme.primaryBlue
                        )
                )
        }
        .scaleEffect(storeName.isEmpty || amount.isEmpty ? 0.98 : 1)
        .animation(.easeInOut(duration: 0.2), value: storeName)
        .animation(.easeInOut(duration: 0.2), value: amount)
        .padding(.top, 10)
        .disabled(storeName.isEmpty || amount.isEmpty)
    }

    // MARK: - Save Logic

    private func saveTicket() {

        guard let amountValue = Double(amount) else { return }

        let newTicket = Ticket(context: context)
        newTicket.id = Int64(Date().timeIntervalSince1970 * 1000)
        newTicket.storeName = storeName
        newTicket.amount = amountValue
        newTicket.category = category
        newTicket.dateMillis = Int64(selectedDate.timeIntervalSince1970 * 1000)
        newTicket.ticketDescription = description

        do {
            try context.save()

            // 🔵 Haptic succès confirmé
            UINotificationFeedbackGenerator().notificationOccurred(.success)

            dismiss()
        } catch {
            print("Erreur sauvegarde:", error)
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
}
