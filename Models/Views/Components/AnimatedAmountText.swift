import SwiftUI

struct AnimatedAmountText: View {

    let value: Double

    @State private var displayed: Double = 0

    var body: some View {
        Text(String(format: "%.2f €", displayed))
            .kerning(-2)
            .onAppear { animate(to: value) }
            .onChange(of: value) { _, newValue in animate(to: newValue) }
    }

    private func animate(to target: Double) {
        withAnimation(.easeOut(duration: 0.6)) {
            displayed = target
        }
    }
}
