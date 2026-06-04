import SwiftUI

struct AnimatedAmountText: View {

    var value: Double
    @State private var displayedValue: Double = 0

    var body: some View {
        Text(String(format: "%.2f €", displayedValue))
            .onAppear {
                withAnimation(.easeOut(duration: 0.6)) {
                    displayedValue = value
                }
            }
    }
}
