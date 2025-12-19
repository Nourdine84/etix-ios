import SwiftUI
import CoreData

struct TicketExportButton: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject private var vm = TicketExportViewModel()

    var body: some View {
        ZStack {
            Button {
                vm.exportCurrentMonth(context: context)
            } label: {
                Image(systemName: "square.and.arrow.up")
            }
            .disabled(vm.isExporting)
        }
        .alert("Export PDF", isPresented: Binding(
            get: { vm.exportError != nil },
            set: { _ in vm.exportError = nil }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(vm.exportError ?? "")
        }
        .sheet(isPresented: $vm.showShareSheet) {
            if let data = vm.pdfData {
                ShareSheet(items: [data])
            }
        }
    }
}
