import SwiftUI

struct KPIExportButton: View {

    let type: KPIType
    let tickets: [Ticket]
    let total: Double
    let variation: Double

    @StateObject private var vm = KPIExportViewModel()

    var body: some View {
        Button {
            vm.export(
                type: type,
                tickets: tickets,
                total: total,
                variation: variation
            )
        } label: {
            Image(systemName: "square.and.arrow.up")
        }
        .sheet(isPresented: $vm.showShareSheet) {
            if let url = vm.fileURL {
                ShareSheet(activityItems: [url])
            }
        }
    }
}
