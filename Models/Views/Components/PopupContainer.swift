import SwiftUI

struct PopupContainer<Content: View>: View {
    let dismissOnBackgroundTap: Bool
    let onDismiss: (() -> Void)?
    let content: Content

    init(
        dismissOnBackgroundTap: Bool = true,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.dismissOnBackgroundTap = dismissOnBackgroundTap
        self.onDismiss = onDismiss
        self.content = content()
    }

    var body: some View {
        ZStack {
            // Background overlay (dim + blur)
            Rectangle()
                .fill(Color.black.opacity(0.40))
                .ignoresSafeArea()
                .onTapGesture {
                    guard dismissOnBackgroundTap else { return }
                    onDismiss?()
                }

            // Card
            content
                .padding(.horizontal, 18)
                .padding(.vertical, 18)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .shadow(color: .black.opacity(0.20), radius: 20, x: 0, y: 10)
                .padding(.horizontal, 26)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.96).combined(with: .opacity),
                    removal: .opacity
                ))
        }
        .animation(.easeInOut(duration: 0.18), value: UUID())
    }
}
