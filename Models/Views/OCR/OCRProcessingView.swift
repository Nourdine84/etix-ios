import SwiftUI

/// Écran de traitement affiché pendant la reconnaissance OCR (hors main thread).
/// Montre les étapes du pipeline pour que l'utilisateur comprenne ce qui se
/// passe, plutôt qu'un gel silencieux.
struct OCRProcessingView: View {

    private let steps = [
        "Analyse de l'image",
        "Reconnaissance du texte",
        "Extraction des informations"
    ]

    @State private var current = 0

    var body: some View {
        ZStack {
            Theme.Background.primary
                .ignoresSafeArea()

            VStack(spacing: Theme.Spacing.section) {
                ProgressView()
                    .controlSize(.large)

                Text("Lecture du ticket…")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)

                VStack(alignment: .leading, spacing: Theme.Spacing.m) {
                    ForEach(steps.indices, id: \.self) { index in
                        HStack(spacing: Theme.Spacing.m) {
                            Image(systemName: icon(for: index))
                                .foregroundColor(index <= current ? Theme.primaryBlue : .secondary)
                            Text(steps[index])
                                .font(Theme.Typography.subheadline)
                                .foregroundColor(index <= current ? .primary : .secondary)
                        }
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.section)
        }
        .task {
            // Progression indicative (la reconnaissance réelle tourne en parallèle).
            for index in steps.indices {
                current = index
                try? await Task.sleep(nanoseconds: 450_000_000)
            }
            current = steps.count - 1
        }
    }

    private func icon(for index: Int) -> String {
        if index < current { return "checkmark.circle.fill" }
        if index == current { return "circle.dotted" }
        return "circle"
    }
}

#Preview {
    OCRProcessingView()
}
