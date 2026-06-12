import SwiftUI

/// Onboarding V2 — structure maquette 2, ambiance maquette 3.
/// 3 pages : Promesse → Mécanique (feature rows) → Payoff.
/// Fond Theme.Background.primary partagé avec le Splash : transition invisible.
struct OnboardingView: View {

    @EnvironmentObject var session: SessionViewModel
    @StateObject private var vm = OnboardingViewModel()

    var body: some View {
        ZStack {
            Theme.Background.primary
                .ignoresSafeArea()

            AmbientBackground(intensity: 0.6, glowOffsetY: -120)

            VStack(spacing: Theme.Spacing.l) {

                header

                // Pages
                TabView(selection: $vm.index) {
                    ForEach(Array(vm.pages.enumerated()), id: \.offset) { i, page in
                        pageView(page)
                            .tag(i)
                            .padding(.horizontal, Theme.Spacing.xxl)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                dots

                PrimaryButton(title: vm.isLastPage ? "Démarrer" : "Suivant") {
                    if vm.isLastPage {
                        vm.skip()
                        session.finishOnboarding()
                    } else {
                        vm.next()
                    }
                }
                .padding(.horizontal, Theme.Spacing.xxl)
                .padding(.bottom, Theme.Spacing.l)
            }
            .padding(.top, Theme.Spacing.m)
        }
        .onAppear {
            if vm.hasSeenOnboarding {
                session.finishOnboarding()
            }
        }
    }

    // MARK: - Header

    /// Badge centré (continuité Splash / headers V2) + « Passer » à droite,
    /// masqué sur la dernière page où « Démarrer » le rend redondant.
    private var header: some View {
        ZStack {
            EtixBadge(size: 56)

            HStack {
                Spacer()
                if !vm.isLastPage {
                    Button("Passer") {
                        Haptic.light()
                        vm.skip()
                        session.finishOnboarding()
                    }
                    .foregroundColor(Theme.primaryBlue)
                    .font(.headline)
                }
            }
            .padding(.horizontal, Theme.Spacing.xxl)
        }
        .animation(.easeInOut(duration: 0.2), value: vm.isLastPage)
    }

    // MARK: - Page

    @ViewBuilder
    private func pageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: Theme.Spacing.xl) {
            Spacer(minLength: 0)

            switch page.hero {
            case .badge:
                EtixBadge(size: 110)
            case .symbol(let name):
                heroSymbol(name)
            case nil:
                EmptyView()
            }

            Text(page.title)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)

            Text(page.subtitle)
                .font(Theme.Typography.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.l)

            if !page.features.isEmpty {
                VStack(spacing: Theme.Spacing.l) {
                    ForEach(page.features, id: \.self) { feature in
                        FeatureRow(feature: feature)
                    }
                }
                .padding(.top, Theme.Spacing.s)
            }

            Spacer(minLength: 0)
        }
    }

    /// Visuel sobre de la page Payoff — symbole bleu dans un cercle glow léger.
    private func heroSymbol(_ name: String) -> some View {
        ZStack {
            Circle()
                .fill(Theme.primaryBlue.opacity(0.10))
            Image(systemName: name)
                .font(.system(size: 48, weight: .semibold))
                .foregroundColor(Theme.primaryBlue)
        }
        .frame(width: 110, height: 110)
    }

    // MARK: - Dots

    private var dots: some View {
        HStack(spacing: 8) {
            ForEach(0..<vm.pages.count, id: \.self) { i in
                Circle()
                    .fill(i == vm.index ? Theme.primaryBlue : Color.secondary.opacity(0.35))
                    .frame(width: i == vm.index ? 10 : 8, height: i == vm.index ? 10 : 8)
                    .animation(.easeInOut(duration: 0.2), value: vm.index)
            }
        }
    }
}

// MARK: - Feature Row

/// Rangée icône ronde + verbe gras + bénéfice — privée : un seul consommateur.
private struct FeatureRow: View {

    let feature: OnboardingPage.Feature

    var body: some View {
        HStack(spacing: Theme.Spacing.l) {
            ZStack {
                Circle()
                    .fill(Theme.primaryBlue.opacity(0.12))
                Image(systemName: feature.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Theme.primaryBlue)
            }
            .frame(width: 44, height: 44)

            (
                Text(feature.keyword)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                + Text(" \(feature.text)")
                    .foregroundColor(.secondary)
            )
            .font(Theme.Typography.subheadline)
            .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
    }
}

#Preview("Light") {
    OnboardingView()
        .environmentObject(SessionViewModel())
}

#Preview("Dark") {
    OnboardingView()
        .environmentObject(SessionViewModel())
        .preferredColorScheme(.dark)
}
