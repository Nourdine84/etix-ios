import SwiftUI

struct CategoryExportButton: View {

    let categoryName: String
    let tickets: [Ticket]
    let total: Double

    @StateObject private var vm = CategoryExportViewModel()

    var body: some View {
        Button {
            vm.export(
                categoryName: categoryName,
                tickets: tickets,
                total: total
            )
        } label: {
            if vm.isExporting {
                ProgressView()
            } else {
                Image(systemName: "square.and.arrow.up")
            }
        }
        .sheet(isPresented: $vm.showShareSheet) {
            if let url = vm.exportedURL {
                ShareSheet(activityItems: [url])
            }
        }
    }
}
