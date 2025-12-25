import SwiftUI
import CoreData

struct HomeV2View: View {

    @Environment(\.managedObjectContext) private var context

    // 🔹 Récupération des derniers tickets
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

            HStack {
                Text("Derniers tickets")
                    .font(.headline)

                Spacer()

                Button("Voir tout") {
                    NotificationCenter.default.post(name: .goToHistory, object: nil)
                }
                .font(.caption)
                .foregroundColor(Color(Theme.primaryBlue))
            }

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
                        .buttonStyle(.plain) // 🔥 garde le style clean iOS
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    var emptyState: some View {
        Text("Aucun ticket enregistré")
            .font(.subheadline)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 12)
    }
}
