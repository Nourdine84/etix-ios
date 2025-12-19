import SwiftUI

struct ErrorPopup: View {
    let title: String
    let message: String
    let buttonTitle: String
    let onClose: () -> Void

    init(
        title: String = "Erreur",
        message: String,
        buttonTitle: String = "Fermer",
        onClose: @escaping () -> Void
    ) {
        self.title = title
        self.message = message
        self.buttonTitle = buttonTitle
        self.onClose = onClose
    }

    var body: some View {
        PopupContainer(dismissOnBackgroundTap: true, onDismiss: onClose) {
            VStack(spacing: 14) {
                Image(systemName: "xmark.octagon.fill")
                    .font(.system(size: 52, weight: .bold))
                    .foregroundColor(.red)

                Text(title)
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Button(action: onClose) {
                    Text(buttonTitle)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.red.opacity(0.92))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .padding(.top, 4)
            }
        }
    }
}
