import SwiftUI

struct TicketFilterSheet: View {

    @Environment(\.dismiss) private var dismiss

    @Binding var startDate: Date?
    @Binding var endDate:   Date?
    var onClear: () -> Void

    @State private var tempStart: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var tempEnd:   Date = Date()

    var body: some View {
        NavigationStack {
            Form {
                Section("Période") {
                    Toggle("Date de début", isOn: Binding(
                        get: { startDate != nil },
                        set: { startDate = $0 ? tempStart : nil }
                    ))

                    if startDate != nil {
                        DatePicker(
                            "Début",
                            selection: Binding(
                                get: { startDate ?? tempStart },
                                set: { startDate = $0; tempStart = $0 }
                            ),
                            displayedComponents: .date
                        )
                    }

                    Toggle("Date de fin", isOn: Binding(
                        get: { endDate != nil },
                        set: { endDate = $0 ? tempEnd : nil }
                    ))

                    if endDate != nil {
                        DatePicker(
                            "Fin",
                            selection: Binding(
                                get: { endDate ?? tempEnd },
                                set: { endDate = $0; tempEnd = $0 }
                            ),
                            in: (startDate ?? .distantPast)...,
                            displayedComponents: .date
                        )
                    }
                }

                Section {
                    Button(role: .destructive) {
                        Haptic.medium()
                        startDate = nil
                        endDate   = nil
                        onClear()
                        dismiss()
                    } label: {
                        Label("Réinitialiser les filtres", systemImage: "xmark.circle")
                    }
                }
            }
            .navigationTitle("Filtres")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Appliquer") {
                        Haptic.light()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let s = startDate { tempStart = s }
                if let e = endDate   { tempEnd   = e }
            }
        }
    }
}
