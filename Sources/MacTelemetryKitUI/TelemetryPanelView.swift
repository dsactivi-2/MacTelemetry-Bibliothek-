import SwiftUI
import MacTelemetryKit

public struct TelemetryPanelView: View {
    @State private var viewModel: TelemetryPanelViewModel

    public init(store: TelemetryStore) {
        _viewModel = State(initialValue: TelemetryPanelViewModel(store: store))
    }

    public var body: some View {
        NavigationSplitView {
            TelemetryFilterSidebar(viewModel: viewModel)
                .frame(minWidth: 260, idealWidth: 260, maxWidth: 260)
        } content: {
            TelemetryEventTable(viewModel: viewModel)
                .frame(minWidth: 420)
        } detail: {
            TelemetryEventDetailPane(event: viewModel.selectedEvent)
                .frame(minWidth: 360, idealWidth: 360, maxWidth: 360)
        }
        .navigationSplitViewStyle(.balanced)
    }
}
