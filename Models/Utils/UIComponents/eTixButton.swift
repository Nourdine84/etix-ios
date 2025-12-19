import SwiftUI

struct eTixButton: View {
    var title: String
    var icon: String? = nil
    var action: () -> Void

    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Button(action: {
            Haptic.light()   // 👉 Nouveau système de feedback
            withAnimation(.spring(response: 0.3)) {
                action()
            }
        }) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.headline)
                }
                
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(Theme.primaryBlue))
            .cornerRadius(12)
            .shadow(
                color: .black.opacity(scheme == .dark ? 0.28 : 0.15),
                radius: 6,
                y: 3
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 20) {
        eTixButton(title: "Enregistrer", icon: "checkmark.circle.fill") {}
        eTixButton(title: "Ajouter un ticket") {}
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
