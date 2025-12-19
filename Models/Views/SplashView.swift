import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [.black.opacity(0.9), Theme.primaryBlue.opacity(0.8)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "ticket.fill")
                    .font(.system(size: 64, weight: .bold))
                    .foregroundColor(.white)
                Text("eTix")
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text("Dématérialisez vos tickets")
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
}
