import SwiftUI
import CoreData

struct BudgetSettingsView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var context

    @State private var budgets: [String: Double] = BudgetStore.load()
    @State private var allCategories: [String] = []
    @State private var editTarget: EditTarget? = nil

    private struct EditTarget: Identifiable {
        let id: String
        let currentLimit: Double?
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(allCategories, id: \.self) { cat in
                        categoryRow(cat)
                    }
                } footer: {
                    Text("Les budgets s'appliquent à la vue mensuelle.")
                }
            }
            .navigationTitle("Budgets mensuels")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fermer") { dismiss() }
                }
            }
            .onAppear { loadCategories() }
            .sheet(item: $editTarget) { target in
                BudgetEditSheet(
                    categoryName: target.id,
                    currentLimit: target.currentLimit
                ) { newLimit in
                    BudgetStore.set(limit: newLimit, for: target.id)
                    budgets = BudgetStore.load()
                }
            }
        }
    }

    private func categoryRow(_ cat: String) -> some View {
        Button {
            editTarget = EditTarget(id: cat, currentLimit: budgets[cat.lowercased()])
        } label: {
            HStack {
                Text(cat)
                    .foregroundColor(.primary)
                Spacer()
                Group {
                    if let limit = budgets[cat.lowercased()] {
                        Text(String(format: "%.0f €", limit))
                            .foregroundColor(.secondary)
                    } else {
                        Text("—")
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                }
                .font(.subheadline)
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundColor(Color(.tertiaryLabel))
            }
        }
    }

    private func loadCategories() {
        let request = NSFetchRequest<NSDictionary>(entityName: "Ticket")
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = ["category"]
        request.returnsDistinctResults = true
        let results = (try? context.fetch(request)) ?? []
        allCategories = results
            .compactMap { $0["category"] as? String }
            .filter { !$0.isEmpty }
            .sorted()
    }
}

// MARK: - Edit Sheet

struct BudgetEditSheet: View {

    @Environment(\.dismiss) private var dismiss

    let categoryName: String
    let currentLimit: Double?
    let onSave: (Double?) -> Void

    @State private var amount: String = ""

    private var parsedAmount: Double? {
        let normalized = amount.replacingOccurrences(of: ",", with: ".")
        guard let value = Double(normalized), value > 0 else { return nil }
        return value
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Ex : 300", text: $amount)
                        .keyboardType(.decimalPad)
                } header: {
                    Text("Budget mensuel — \(categoryName)")
                }

                if currentLimit != nil {
                    Section {
                        Button(role: .destructive) {
                            onSave(nil)
                            dismiss()
                        } label: {
                            Label("Supprimer le budget", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle(categoryName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Appliquer") {
                        if let value = parsedAmount {
                            onSave(value)
                        }
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(parsedAmount == nil)
                }
            }
            .onAppear {
                if let limit = currentLimit {
                    amount = String(format: "%.0f", limit)
                }
            }
        }
    }
}
