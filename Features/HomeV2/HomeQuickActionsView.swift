import SwiftUI

struct HomeQuickActionsView: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("Actions rapides")
                .font(.headline)

            HStack(spacing: 16) {

                quickButton(
                    title: "Ajouter",
                    icon: "plus.circle.fill",
                    color: .blue
                )

                quickButton(
                    title: "Historique",
                    icon: "clock.fill",
                    color: .orange
                )
            }
        }
    }

    private func quickButton(title: String, icon: String, color: Color) -> some View {
        Button(action: {
            // Navigation V2 → à brancher
        }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 26))
                Text(title)
                    .font(.subheadline)
            }
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .padding()
            .background(color.opacity(0.12))
            .cornerRadius(16)
        }
    }
}
