import SwiftUI
import CoreData

struct HomeV2View: View {

    @Environment(\.managedObjectContext) private var context

    // 🔹 Derniers tickets
    @FetchRequest(
        entity: Ticket.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Ticket.dateMillis, ascending: false)
        ],
        animation: .easeInOut
    )
    private var tickets: FetchedResults<Ticket>

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {

                    // MARK: - Derniers tickets
                    lastTicketsSection

                }
                .padding()
            }
            .navigationTitle("Accueil")
        }
    }
}

// MARK: - Sections
private extension HomeV2View {

    var lastTicketsSection: some View {
        VStack(alignment: .leading, spacing: 12) {

            header

            if tickets.isEmpty {
                emptyState
            } else {
                VStack(spacing: 10) {
                    ForEach(tickets.prefix(5), id: \.objectID) { ticket in
                        NavigationLink {
                            TicketDetailView(ticket: ticket)
                        } label: {
                            LastTicketRow(ticket: ticket)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    var header: some View {
        HStack {
            Text("Derniers tickets")
                .font(.headline)

            Spacer()

            if !tickets.isEmpty {
                Button("Voir tout") {
                    NotificationCenter.default.post(
                        name: .goToHistory,
                        object: nil
                    )
                }
                .font(.caption)
                .foregroundColor(Color(Theme.primaryBlue))
            }
        }
    }

    // ✅ EMPTY STATE AMÉLIORÉ
    var emptyState: some View {
        VStack(spacing: 14) {

            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 36))
                .foregroundColor(Color(Theme.primaryBlue))
                .opacity(0.9)

            Text("Aucun ticket enregistré")
                .font(.headline)

            Text("Ajoutez votre premier ticket pour commencer à suivre vos dépenses.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)

            Button {
                Haptic.light()
                NotificationCenter.default.post(
                    name: .goToAddTicket,
                    object: nil
                )
            } label: {
                Text("Ajouter un ticket")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 12)
                    .background(Color(Theme.primaryBlue))
                    .foregroundColor(.white)
                    .cornerRadius(14)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
    }
}
