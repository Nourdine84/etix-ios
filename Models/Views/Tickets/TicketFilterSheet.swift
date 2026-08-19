import SwiftUI

/// Filtres History V2 — **bottom sheet à detents**, ouverte par le seul bouton
/// explicite « Filtres ». Répond à « comment je réduis le résultat ? »
/// (la recherche, elle, répond à « de quoi je me souviens ? »).
///
/// Incrément 1 : **période · montant · tri**. `HistoryQuery` porte déjà
/// catégories/magasins ; ils se brancheront ici sans changer l'architecture.
struct TicketFilterSheet: View {

    @Environment(\.dismiss) private var dismiss

    @Binding var startDate: Date?
    @Binding var endDate:   Date?
    @Binding var minAmount: Double?
    @Binding var maxAmount: Double?
    @Binding var sort: HistorySort

    var onReset: () -> Void

    // Dates de repli quand un toggle active une borne encore vide.
    @State private var tempStart: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var tempEnd: Date = Date()

    var body: some View {
        NavigationStack {
            Form {

                // MARK: Période
                Section("Période") {
                    Toggle("Depuis une date", isOn: startEnabled)
                    if startDate != nil {
                        DatePicker("Début", selection: startBinding, displayedComponents: .date)
                    }
                    Toggle("Jusqu'à une date", isOn: endEnabled)
                    if endDate != nil {
                        DatePicker("Fin", selection: endBinding, displayedComponents: .date)
                    }
                }

                // MARK: Montant
                Section("Montant") {
                    amountRow(label: "Min", binding: $minAmount)
                    amountRow(label: "Max", binding: $maxAmount)
                }

                // MARK: Tri
                Section("Tri") {
                    Picker("Tri", selection: $sort) {
                        ForEach(HistorySort.allCases, id: \.self) { option in
                            Text(title(option)).tag(option)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }

                // MARK: Réinitialiser
                Section {
                    Button(role: .destructive) {
                        Haptic.medium()
                        onReset()
                    } label: {
                        Label("Réinitialiser les filtres", systemImage: "arrow.counterclockwise")
                    }
                }
            }
            .navigationTitle("Filtres")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("OK") { dismiss() }
                }
            }
            .onAppear {
                if let s = startDate { tempStart = s }
                if let e = endDate { tempEnd = e }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Ligne montant

    private func amountRow(label: String, binding: Binding<Double?>) -> some View {
        HStack {
            Text(label)
            Spacer()
            TextField("—", text: amountText(binding))
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
            Text("€").foregroundColor(.secondary)
        }
    }

    // MARK: - Bindings période

    private var startEnabled: Binding<Bool> {
        Binding(
            get: { startDate != nil },
            set: { startDate = $0 ? tempStart : nil }
        )
    }
    private var endEnabled: Binding<Bool> {
        Binding(
            get: { endDate != nil },
            set: { endDate = $0 ? tempEnd : nil }
        )
    }
    private var startBinding: Binding<Date> {
        Binding(
            get: { startDate ?? tempStart },
            set: { startDate = $0; tempStart = $0 }
        )
    }
    private var endBinding: Binding<Date> {
        Binding(
            get: { endDate ?? tempEnd },
            set: { endDate = $0; tempEnd = $0 }
        )
    }

    // MARK: - Binding montant (texte ↔ Double?), live via AmountParser

    private func amountText(_ source: Binding<Double?>) -> Binding<String> {
        Binding(
            get: { source.wrappedValue.map { String(format: "%.2f", $0) } ?? "" },
            set: { source.wrappedValue = AmountParser.parse($0) }
        )
    }

    // MARK: - Libellés tri

    private func title(_ sort: HistorySort) -> String {
        switch sort {
        case .recentFirst: return "Plus récents"
        case .oldestFirst: return "Plus anciens"
        case .amountDesc:  return "Montant décroissant"
        case .amountAsc:   return "Montant croissant"
        }
    }
}
