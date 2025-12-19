import SwiftUI

struct SplashView: View {
    @EnvironmentObject var session: SessionViewModel

    @State private var scale: CGFloat = 0.75
    @State private var opacity: Double = 0.0
    @State private var glowOpacity: Double = 0.0
    @State private var rotation: Double = 0.0

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(.systemBackground), Color(.secondarySystemBackground)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ZStack {
                Circle()
                    .fill(Color(Theme.primaryBlue).opacity(0.15))
                    .frame(width: 260, height: 260)
                    .blur(radius: 30)
                    .opacity(glowOpacity)

                Group {
                    if UIImage(named: "eTixLogo") != nil {
                        Image("eTixLogo")
                            .resizable()
                            .scaledToFit()
                    } else {
                        Image(systemName: "ticket.fill")
                            .font(.system(size: 96, weight: .bold))
                            .foregroundStyle(Color(Theme.primaryBlue))
                    }
                }
                .frame(width: 140, height: 140)
                .scaleEffect(scale)
                .rotationEffect(.degrees(rotation))
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.2)) {
                        opacity = 1.0
                        scale = 1.05
                        glowOpacity = 1.0
                    }
                    withAnimation(.spring(response: 1.4, dampingFraction: 0.6)) {
                        rotation = 360
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            session.decideNextAfterSplash()
                        }
                    }
                }
            }

            VStack {
                Spacer()
                VStack(spacing: 4) {
                    Text("eTix")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text("Dématérialisez vos tickets")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 60)
            }
        }
    }
}

#Preview {
    SplashView()
        .environmentObject(SessionViewModel())
}
