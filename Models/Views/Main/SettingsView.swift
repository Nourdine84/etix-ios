import SwiftUI
import CoreData

struct SettingsView: View {

    @Environment(\.managedObjectContext) private var context
    @StateObject private var vm = SettingsViewModel()

    var body: some View {
        NavigationStack {
            List {

                appearanceSection
                rangeSection
                dataSection
                infoSection
            }
            .navigationTitle("Réglages")
            .alert("Confirmer la suppression ?", isPresented: $vm.showResetAlert) {
                Button("Supprimer", role: .destructive) {
                    vm.resetDatabase(context: context)
                }
                Button("Annuler", role: .cancel) {}
            } message: {
                Text("Tous les tickets seront définitivement supprimés.")
            }
            .sheet(isPresented: $vm.showExportSheet) {
                if let url = vm.exportedFileURL {
                    ShareSheet(items: [url])
                }
            }
        }
    }

    // MARK: Sections

    private var appearanceSection: some View {
        Section(header: Text("Apparence")) {
            Picker("Thème", selection: $vm.settings.appearance) {
                ForEach(AppAppearance.allCases, id: \.self) { appearance in
                    Text(appearance.title).tag(appearance)
                }
            }
            .onChange(of: vm.settings.appearance) { _ in
                vm.persistChanges()
            }
        }
    }

    private var rangeSection: some View {
        Section(header: Text("Période par défaut")) {
            Picker("Période", selection: $vm.settings.defaultRange) {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    Text(range.title).tag(range)
                }
            }
            .onChange(of: vm.settings.defaultRange) { _ in
                vm.persistChanges()
            }
        }
    }

    private var dataSection: some View {
        Section(header: Text("Données")) {

            Button {
                vm.exportAllTickets(context: context)
            } label: {
                Label("Exporter tous les tickets", systemImage: "square.and.arrow.up")
            }

            Button(role: .destructive) {
                vm.showResetAlert = true
            } label: {
                Label("Supprimer tous les tickets", systemImage: "trash")
            }
        }
    }

    private var infoSection: some View {
        Section(header: Text("Informations")) {

            HStack {
                Text("Version")
                Spacer()
                Text(vm.settings.appVersion)
                    .foregroundColor(.secondary)
            }

            HStack {
                Text("Build")
                Spacer()
                Text(vm.settings.buildNumber)
                    .foregroundColor(.secondary)
            }
        }
    }
}
