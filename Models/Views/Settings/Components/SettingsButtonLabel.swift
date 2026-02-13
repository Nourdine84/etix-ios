import SwiftUI

struct SettingsButtonLabel: View {

    let title: String
    let icon: String
    var color: Color = Theme.primaryBlue

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)

            Text(title)
                .foregroundColor(color)

            Spacer()
        }
        .font(.subheadline)
        .padding(.vertical, 6)
    }
}
