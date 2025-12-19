import SwiftUI

struct RangePickerSheet: View {
    @Binding var startDate: Date?
    @Binding var endDate: Date?

    let onValidate: () -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Plage personnalisée")) {
                    DatePicker(
                        "Début",
                        selection: Binding(
                            get: { startDate ?? Date() },
                            set: { startDate = $0 }
                        ),
                        displayedComponents: .date
                    )

                    DatePicker(
                        "Fin",
                        selection: Binding(
                            get: { endDate ?? Date() },
                            set: { endDate = $0 }
                        ),
                        displayedComponents: .date
                    )
                }
            }
            .navigationTitle("Sélection des dates")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Valider") { onValidate() }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { onCancel() }
                }
            }
        }
    }
}
