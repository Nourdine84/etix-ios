import SwiftUI
import CoreData

struct SettingsView: View {

    // MARK: - CoreData
    @Environment(\.managedObjectContext) private var context

    // MARK: - ViewModel
    @StateObject private var vm = SettingsViewModel()

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    appearanceSection
                    defaultRangeSection
                    dataSection
                    infoSection
                }
                .padding()
            }
            .navigationTitle("Réglages")
            .background(Color(.systemGroupedBackground))
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
}

//
// MARK: - Sections
//

private extension SettingsView {

    var appearanceSection: some View {
        SettingsCard(title: "Apparence", icon: "paintbrush.fill") {
            Picker("Thème", selection: $vm.settings.appearance) {
                ForEach(AppAppearance.allCases) { appearance in
                    Text(appearance.title).tag(appearance)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    var defaultRangeSection: some View {
        SettingsCard(title: "Période par défaut", icon: "calendar") {
            Picker("Période", selection: $vm.settings.defaultRange) {
                ForEach(TimeRange.allCases) { range in
                    Text(range.title).tag(range)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    var dataSection: some View {
        SettingsCard(title: "Données", icon: "tray.full.fill") {

            Button {
                vm.exportAllTickets(context: context)
            } label: {
                SettingsButtonLabel(
                    title: "Exporter tous les tickets",
                    icon: "square.and.arrow.up"
                )
            }

            Divider()

            Button(role: .destructive) {
                vm.showResetAlert = true
            } label: {
                SettingsButtonLabel(
                    title: "Supprimer tous les tickets",
                    icon: "trash",
                    color: .red
                )
            }
        }
    }

    var infoSection: some View {
        SettingsCard(title: "Informations", icon: "info.circle.fill") {
            infoRow(title: "Version", value: vm.settings.appVersion)
            Divider()
            infoRow(title: "Build", value: vm.settings.buildNumber)
        }
    }

    func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.primary)

            Spacer()

            Text(value)
                .foregroundColor(.secondary)
        }
        .font(.subheadline)
    }
}
