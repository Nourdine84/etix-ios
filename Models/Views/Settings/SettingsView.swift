import SwiftUI
import CoreData

struct SettingsView: View {

    @Environment(\.managedObjectContext) private var context
    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        NavigationStack {
            ZStack {

                DesignSystem.pageBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 36) {

                        appearanceSection
                            .premiumAppear()

                        dataSection
                            .premiumAppear()

                        securitySection
                            .premiumAppear()

                        infoSection
                            .premiumAppear()
                    }
                    .padding(.horizontal, DesignSystem.horizontalPadding)
                    .padding(.vertical, 40)
                }
            }
            .navigationTitle("Réglages")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 14) {

            Text("Apparence")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Picker("Thème", selection: $viewModel.settings.appearance) {
                ForEach(AppAppearance.allCases) {
                    Text($0.title).tag($0)
                }
            }
            .pickerStyle(.segmented)

            Picker("Période par défaut", selection: $viewModel.settings.defaultRange) {
                ForEach(TimeRange.allCases) {
                    Text($0.title).tag($0)
                }
            }
            .pickerStyle(.menu)
        }
        .premiumCard()
    }

    private var dataSection: some View {
        VStack(alignment: .leading, spacing: 18) {

            Text("Données")
                .font(.subheadline)
                .foregroundColor(.secondary)

            settingsRow(icon: "square.and.arrow.up", title: "Exporter CSV")
            settingsRow(icon: "doc.richtext", title: "Exporter PDF")

            settingsRow(icon: "trash", title: "Supprimer tous les tickets", destructive: true)
        }
        .premiumCard()
    }

    private var securitySection: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("Sécurité")
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack {
                Image(systemName: "lock.shield")
                    .foregroundColor(Theme.primaryBlue)

                Text("Vos données sont stockées localement")
                    .font(.footnote)
                    .foregroundColor(.secondary)

                Spacer()
            }
        }
        .premiumCard()
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("Informations")
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack {
                Text("Version")
                Spacer()
                Text(viewModel.settings.appVersion)
                    .foregroundColor(.secondary)
            }

            HStack {
                Text("Build")
                Spacer()
                Text(viewModel.settings.buildNumber)
                    .foregroundColor(.secondary)
            }
        }
        .premiumCard()
    }

    private func settingsRow(icon: String, title: String, destructive: Bool = false) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(destructive ? .red : Theme.primaryBlue)

            Text(title)
                .foregroundColor(destructive ? .red : .primary)

            Spacer()
        }
    }
}
