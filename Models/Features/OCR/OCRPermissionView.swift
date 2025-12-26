import SwiftUI

struct OCRPermissionView: View {

    @StateObject private var vm = OCRViewModel()

    var body: some View {
        VStack(spacing: 24) {

            Spacer()

            // 📸 Icône caméra
            Image(systemName: "camera")
                .font(.system(size: 48))
                .foregroundColor(Color(Theme.primaryBlue))

            // 📝 Texte principal
            Text("Autoriser la caméra")
                .font(.title2)
                .fontWeight(.semibold)

            Text("""
Permission caméra
pour scanner tes tickets

L’application a besoin d’accéder à la caméra
pour scanner et analyser tes tickets.
Aucune image ne sera envoyée sur un serveur.
""")
            .font(.footnote)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)

            Spacer()

            // 🔵 Bouton principal
            eTixButton(
                title: "AUTORISER",
                icon: "camera.fill"
            ) {
                Haptic.light()
                vm.requestPermission()
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .onChange(of: vm.permissionState) { state in
            if state == .authorized {
                NotificationCenter.default.post(
                    name: .goToOCRScanner,
                    object: nil
                )
            }
        }
    }
}

#Preview {
    OCRPermissionView()
}
