import SwiftUI

struct LoginView: View {
    @EnvironmentObject var session: SessionViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Connexion")
                    .font(.title).bold()

                TextField("Email", text: $email)
                    .textContentType(.username)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .padding().background(.ultraThinMaterial).clipShape(RoundedRectangle(cornerRadius: 12))

                SecureField("Mot de passe", text: $password)
                    .textContentType(.password)
                    .padding().background(.ultraThinMaterial).clipShape(RoundedRectangle(cornerRadius: 12))

                Button {
                    session.login()
                } label: {
                    Text("Se connecter")
                        .frame(maxWidth: .infinity).padding()
                        .background(Theme.primaryBlue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .font(.headline)
                }

                Button("Créer un compte") { showRegister = true }
                    .padding(.top, 8)

                Spacer()
            }
            .padding()
            .navigationDestination(isPresented: $showRegister) {
                RegisterView()
            }
        }
    }
}
