import SwiftUI

struct HomeSkeletonView: View {

    var body: some View {
        VStack(spacing: 16) {

            ForEach(0..<3, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemGray5))
                    .frame(height: 70)
                    .shimmer()
            }
        }
        .padding(.vertical)
    }
}
