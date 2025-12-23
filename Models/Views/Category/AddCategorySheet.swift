import SwiftUI

struct AddCategorySheet: View {

    @Environment(\.dismiss) private var dismiss
    @ObservedObject var vm: CategoryCRUDViewModel

    @State private var name = ""
    @State private var icon = "cart.fill"
    @State private var colorHex = "#3B82F6"

    var body: some View {
        NavigationView {
            Form {

                Section(header: Text("Nom")) {
                    TextField("Nom de la catégorie", text: $name)
                }

                Section(header: Text("Icône SF Symbol")) {
                    TextField("ex: cart.fill", text: $icon)
                }

                Section(header: Text("Couleur (hex)")) {
                    TextField("#3B82F6", text: $colorHex)
                }
            }
            .navigationTitle("Nouvelle catégorie")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ajouter") {
                        vm.addCategory(
                            name: name,
                            icon: icon,
                            colorHex: colorHex
                        )
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
            }
        }
    }
}
