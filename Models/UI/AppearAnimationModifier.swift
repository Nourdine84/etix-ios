import SwiftUI

struct AppearAnimationModifier: ViewModifier {

    @State private var visible = false

    func body(content: Content) -> some View {
        content
            .opacity(visible ? 1 : 0)
            .offset(y: visible ? 0 : 18)
            .animation(.easeOut(duration: 0.45), value: visible)
            .onAppear {
                visible = true
            }
    }
}

extension View {
    func premiumAppear() -> some View {
        modifier(AppearAnimationModifier())
    }
}
