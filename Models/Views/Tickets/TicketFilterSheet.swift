import SwiftUI

struct TicketFilterSheet: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var startDate: Date?
    @Binding var endDate: Date?
    var onClear: () -> Void

    // Dates locales éditables
    @State private var tempStart: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var tempEnd: Date = Date()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Période")) {
                    Toggle("Activer une date de début", isOn: Binding(
                        get: { startDate != nil },
                        set: { isOn in
                            if isOn {
                                startDate = tempStart
                            } else {
                                startDate = nil
                            }
                        }
                    ))

                    if startDate != nil {
                        DatePicker(
                            "Date de début",
                            selection: Binding(
                                get: { startDate ?? tempStart },
                                set: { newValue in
                                    startDate = newValue
                                    tempStart = newValue
                                }
                            ),
                            displayedComponents: .date
                        )
                    }

                    Toggle("Activer une date de fin", isOn: Binding(
                        get: { endDate != nil },
                        set: { isOn in
                            if isOn {
                                endDate = tempEnd
                            } else {
                                endDate = nil
                            }
                        }
                    ))

                    if endDate != nil {
                        DatePicker(
                            "Date de fin",
                            selection: Binding(
                                get: { endDate ?? tempEnd },
                                set: { newValue in
                                    endDate = newValue
                                    tempEnd = newValue
                                }
                            ),
                            displayedComponents: .date
                        )
                    }
                }

                Section {
                    Button {
                        Haptic.light()
                        applyCurrentRange()
                    } label: {
                        Label("Appliquer les filtres", systemImage: "line.3.horizontal.decrease.circle")
                            .foregroundColor(Color(Theme.primaryBlue))
                    }

                    Button(role: .destructive) {
                        Haptic.medium()
                        clearAll()
                    } label: {
                        Label("Réinitialiser", systemImage: "xmark.circle")
                    }
                }
            }
            .navigationTitle("Filtres")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                // Sync initial avec les valeurs actuelles
                if let s = startDate { tempStart = s }
                if let e = endDate { tempEnd = e }
            }
        }
    }

    // MARK: - Actions

    private func applyCurrentRange() {
        // Les bindings sont déjà mis à jour via les DatePicker / Toggle
        dismiss()
    }

    private func clearAll() {
        startDate = nil
        endDate = nil
        onClear()
        dismiss()
    }
}
