import SwiftUI
import CoreData

struct SettingsView: View {

    @Environment(\.managedObjectContext) private var context
    @StateObject private var vm = SettingsViewModel()

    var body: some View {
        NavigationStack {
            ZStack {

                // 🔵 Background Premium
                LinearGradient(
                    colors: [
                        Theme.primaryBlue.opacity(0.05),
                        Color(.systemGroupedBackground)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {

                        appearanceSection
                        defaultRangeSection
                        dataSection
                        infoSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 30)
                }
            }
            .navigationTitle("Réglages")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(.systemBackground), for: .navigationBar)
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

    // MARK: - Appearance

    private var appearanceSection: some View {
        settingsCard(title: "Apparence") {
            Picker("Thème", selection: $vm.settings.appearance) {
                ForEach(AppAppearance.allCases) { appearance in
                    Text(appearance.title).tag(appearance)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    // MARK: - Default Range

    private var defaultRangeSection: some View {
        settingsCard(title: "Période par défaut") {
            Picker("Période", selection: $vm.settings.defaultRange) {
                ForEach(TimeRange.allCases) { range in
                    Text(range.title).tag(range)
                }
            }
            .pickerStyle(.menu)
        }
    }

    // MARK: - Data Section

    private var dataSection: some View {
        settingsCard(title: "Données") {

            Button {
                vm.exportAllTickets(context: context)
            } label: {
                settingsButton(
                    icon: "square.and.arrow.up",
                    title: "Exporter en CSV"
                )
            }

            Button {
                vm.exportAllTicketsPDF(context: context)
            } label: {
                settingsButton(
                    icon: "doc.richtext",
                    title: "Exporter en PDF"
                )
            }

            Button(role: .destructive) {
                vm.showResetAlert = true
            } label: {
                settingsButton(
                    icon: "trash",
                    title: "Supprimer tous les tickets",
                    destructive: true
                )
            }
        }
    }

    // MARK: - Info Section

    private var infoSection: some View {
        settingsCard(title: "Informations") {
            infoRow(title: "Version", value: vm.settings.appVersion)
            infoRow(title: "Build", value: vm.settings.buildNumber)
        }
    }

    // MARK: - Components

    private func settingsCard<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {

        VStack(alignment: .leading, spacing: 14) {

            Text(title)
                .font(.headline)

            content()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
        )
    }

    private func settingsButton(
        icon: String,
        title: String,
        destructive: Bool = false
    ) -> some View {

        HStack {
            Image(systemName: icon)
                .foregroundColor(destructive ? .red : Theme.primaryBlue)

            Text(title)
                .foregroundColor(destructive ? .red : .primary)

            Spacer()
        }
        .padding(.vertical, 6)
    }

    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}
