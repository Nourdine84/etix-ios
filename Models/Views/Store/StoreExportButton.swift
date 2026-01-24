import SwiftUI

struct StoreExportButton: View {

    let storeName: String
    let tickets: [Ticket]
    let total: Double

    @StateObject private var vm = StoreExportViewModel()

    var body: some View {
        Button {
            vm.export(
                storeName: storeName,
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
        .disabled(vm.isExporting)
        .sheet(isPresented: $vm.showShareSheet) {
            if let url = vm.exportURL {
                ShareSheet(activityItems: [url])
            }
        }
    }
}
