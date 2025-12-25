import SwiftUI

struct HomeQuickActionsView: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            Text("Actions rapides")
                .font(.headline)
                .padding(.horizontal)

            HStack(spacing: 12) {

                actionButton(
                    title: "Ajouter",
                    icon: "plus.circle.fill",
                    color: Theme.primaryBlue
                ) {
                    NotificationCenter.default.post(
                        name: .goToAddTicket,
                        object: nil
                    )
                }

                actionButton(
                    title: "Historique",
                    icon: "list.bullet.rectangle",
                    color: .secondary
                ) {
                    NotificationCenter.default.post(
                        name: .goToHistory,
                        object: nil
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Subviews
private extension HomeQuickActionsView {

    func actionButton(
        title: String,
        icon: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            Haptic.light()
            action()
        } label: {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))

                Text(title)
                    .font(.footnote)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(color)
            .cornerRadius(14)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeQuickActionsView()
        .padding()
}
