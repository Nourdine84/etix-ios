import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var session: SessionViewModel
    @StateObject private var vm = OnboardingViewModel()

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(.systemBackground), Color(.secondarySystemBackground)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {

                // Header
                HStack {
                    Spacer()
                    Button("Passer") {
                        Haptic.light()
                        vm.skip()
                        session.finishOnboarding()
                    }
                    .foregroundColor(Color(Theme.primaryBlue))
                    .font(.headline)
                }
                .padding(.horizontal)

                // Pages
                TabView(selection: $vm.index) {
                    ForEach(Array(vm.pages.enumerated()), id: \.offset) { i, page in
                        VStack(spacing: 20) {

                            AnimatedPageSymbol(
                                systemImage: page.systemImage,
                                accent: page.accent,
                                index: i
                            )

                            Text(page.title)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .multilineTextAlignment(.center)

                            Text(page.subtitle)
                                .font(.system(size: 16))
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)

                            Spacer(minLength: 0)
                        }
                        .tag(i)
                        .padding(.horizontal)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxHeight: 460)

                // Dots indicator
                HStack(spacing: 8) {
                    ForEach(0..<vm.pages.count, id: \.self) { i in
                        Circle()
                            .fill(i == vm.index ? Color(Theme.primaryBlue) : Color.secondary.opacity(0.35))
                            .frame(width: i == vm.index ? 10 : 8, height: i == vm.index ? 10 : 8)
                            .animation(.easeInOut(duration: 0.2), value: vm.index)
                    }
                }

                // CTA Button
                eTixButton(
                    title: vm.isLastPage ? "Commencer" : "Continuer",
                    icon: vm.isLastPage ? "checkmark.circle.fill" : "arrow.right.circle.fill"
                ) {
                    Haptic.medium()
                    if vm.isLastPage {
                        vm.skip()
                        session.finishOnboarding()
                    } else {
                        vm.next()
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
            .padding(.top, 12)
        }
        .onAppear {
            if vm.hasSeenOnboarding {
                session.finishOnboarding()
            }
        }
    }
}

