import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var confirm = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Inscription").font(.title).bold()

            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .padding().background(.ultraThinMaterial).clipShape(RoundedRectangle(cornerRadius: 12))

            SecureField("Mot de passe", text: $password)
                .padding().background(.ultraThinMaterial).clipShape(RoundedRectangle(cornerRadius: 12))

            SecureField("Confirmer le mot de passe", text: $confirm)
                .padding().background(.ultraThinMaterial).clipShape(RoundedRectangle(cornerRadius: 12))

            Button {
                dismiss() // mocked
            } label: {
                Text("Créer mon compte")
                    .frame(maxWidth: .infinity).padding()
                    .background(Theme.primaryBlue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .font(.headline)
            }

            Spacer()
        }
        .padding()
    }
}
