import SwiftUI
import CoreData

struct CategoryPickerSheet: View {

    @Environment(\.dismiss) private var dismiss

    @Binding var selectedCategory: String
    let context: NSManagedObjectContext

    @State private var showCustomField = false
    @State private var customText = ""

    private let systemCategories = [
        "Alimentation", "Restaurant", "Transport", "Santé", "Sport",
        "Maison", "Vêtements", "Culture", "High-Tech", "Beauté",
        "Carburant", "Abonnement"
    ]

    private var usedCategories: [String] {
        let request = NSFetchRequest<NSDictionary>(entityName: "Ticket")
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = ["category"]
        request.returnsDistinctResults = true
        let results = (try? context.fetch(request)) ?? []
        return results
            .compactMap { $0["category"] as? String }
            .filter { !$0.isEmpty && !systemCategories.contains($0) && $0 != "Autre" }
            .sorted()
    }

    private var allCategories: [String] {
        systemCategories + usedCategories
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(allCategories, id: \.self) { cat in
                        categoryRow(cat)
                    }
                }

                Section {
                    if showCustomField {
                        HStack(spacing: 8) {
                            TextField("Nom de la catégorie", text: $customText)
                                .textInputAutocapitalization(.words)
                                .submitLabel(.done)
                                .onSubmit { applyCustom() }

                            Button("OK") { applyCustom() }
                                .fontWeight(.semibold)
                                .foregroundColor(Theme.primaryBlue)
                                .disabled(customText.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                    } else {
                        Button {
                            showCustomField = true
                        } label: {
                            Label("Autre…", systemImage: "plus.circle")
                                .foregroundColor(Theme.primaryBlue)
                        }
                    }
                }
            }
            .navigationTitle("Catégorie")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { dismiss() }
                }
                if !selectedCategory.isEmpty {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Effacer") {
                            selectedCategory = ""
                            dismiss()
                        }
                        .foregroundColor(.secondary)
                    }
                }
            }
        }
    }

    private func categoryRow(_ cat: String) -> some View {
        Button {
            selectedCategory = cat
            dismiss()
        } label: {
            HStack {
                Text(cat)
                    .foregroundColor(.primary)
                Spacer()
                if selectedCategory == cat {
                    Image(systemName: "checkmark")
                        .foregroundColor(Theme.primaryBlue)
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private func applyCustom() {
        let trimmed = customText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        selectedCategory = trimmed
        dismiss()
    }
}
