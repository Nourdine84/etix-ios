import SwiftUI
import CoreData

struct SettingsView: View {

    @Environment(\.managedObjectContext) private var context
    @StateObject private var vm = SettingsViewModel()

    @FetchRequest(fetchRequest: Ticket.fetchAllRequest())
    private var tickets: FetchedResults<Ticket>

    var body: some View {
        NavigationStack {
            List {
                appearanceSection
                rangeSection
                dataSection
                infoSection
                devSection
            }
            .navigationTitle("Réglages")
            .alert("Confirmer la suppression ?", isPresented: $vm.showResetAlert) {
                Button("Supprimer", role: .destructive) {
                    vm.resetDatabase(context: context)
                }
                Button("Annuler", role: .cancel) {}
            } message: {
                Text("Les \(tickets.count) tickets seront définitivement supprimés.")
            }
            .sheet(isPresented: $vm.showExportSheet) {
                if let url = vm.exportedFileURL {
                    ShareSheet(items: [url])
                }
            }
        }
    }

    // MARK: - Sections

    private var appearanceSection: some View {
        Section {
            Picker(selection: $vm.settings.appearance) {
                ForEach(AppAppearance.allCases) { appearance in
                    Label(appearance.title, systemImage: appearance.icon).tag(appearance)
                }
            } label: {
                Label("Thème", systemImage: "paintbrush")
            }
            .onChange(of: vm.settings.appearance) { _, _ in
                vm.persistChanges()
            }
        } header: {
            Text("Apparence")
        }
    }

    private var rangeSection: some View {
        Section {
            Picker(selection: $vm.settings.defaultRange) {
                ForEach(TimeRange.allCases) { range in
                    Text(range.title).tag(range)
                }
            } label: {
                Label("Période par défaut", systemImage: "calendar")
            }
            .onChange(of: vm.settings.defaultRange) { _, _ in
                vm.persistChanges()
            }
        } header: {
            Text("Affichage")
        }
    }

    private var dataSection: some View {
        Section {
            Button {
                vm.exportAllTickets(context: context)
            } label: {
                Label("Exporter en CSV", systemImage: "square.and.arrow.up")
            }
            .disabled(tickets.isEmpty)

            Button(role: .destructive) {
                vm.showResetAlert = true
            } label: {
                Label("Supprimer tous les tickets", systemImage: "trash")
            }
            .disabled(tickets.isEmpty)

        } header: {
            Text("Données")
        } footer: {
            Text("\(tickets.count) ticket(s) enregistré(s)")
        }
    }

    private var infoSection: some View {
        Section("Informations") {
            LabeledContent("Version", value: vm.settings.appVersion)
            LabeledContent("Build", value: vm.settings.buildNumber)
        }
    }

    // TODO: remove before release
    private var devSection: some View {
        Section {
            Button(role: .destructive) {
                UserDefaults.standard.removeObject(forKey: "app.hasSeenOnboarding")
            } label: {
                Label("Réinitialiser l'onboarding", systemImage: "arrow.counterclockwise")
            }
        } header: {
            Text("Développement")
        } footer: {
            Text("Supprime le flag onboarding. Relancer l'app pour voir l'effet.")
        }
    }
}
