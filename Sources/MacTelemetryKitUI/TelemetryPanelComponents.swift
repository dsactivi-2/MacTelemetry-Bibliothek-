import SwiftUI
import MacTelemetryKit

struct TelemetryFilterSidebar: View {
    @Bindable var viewModel: TelemetryPanelViewModel

    var body: some View {
        Form {
            Section("Categories") {
                ForEach(TelemetryCategory.allCases, id: \.self) { category in
                    Toggle(category.rawValue.capitalized, isOn: categoryBinding(for: category))
                }
            }

            Section("Levels") {
                ForEach(TelemetryLevel.allCases, id: \.self) { level in
                    Toggle(level.rawValue.capitalized, isOn: levelBinding(for: level))
                }
            }

            Section("Frameworks") {
                ForEach(TelemetrySource.allCases, id: \.self) { source in
                    Toggle(source.rawValue, isOn: sourceBinding(for: source))
                }
            }
        }
        .formStyle(.grouped)
    }

    private func categoryBinding(for category: TelemetryCategory) -> Binding<Bool> {
        Binding(
            get: { viewModel.filter.categories.contains(category) },
            set: { isOn in
                if isOn {
                    viewModel.filter.categories.insert(category)
                } else {
                    viewModel.filter.categories.remove(category)
                }
            }
        )
    }

    private func levelBinding(for level: TelemetryLevel) -> Binding<Bool> {
        Binding(
            get: { viewModel.filter.levels.contains(level) },
            set: { isOn in
                if isOn {
                    viewModel.filter.levels.insert(level)
                } else {
                    viewModel.filter.levels.remove(level)
                }
            }
        )
    }

    private func sourceBinding(for source: TelemetrySource) -> Binding<Bool> {
        Binding(
            get: { viewModel.filter.sources.contains(source) },
            set: { isOn in
                if isOn {
                    viewModel.filter.sources.insert(source)
                } else {
                    viewModel.filter.sources.remove(source)
                }
            }
        )
    }
}

struct TelemetryEventTable: View {
    @Bindable var viewModel: TelemetryPanelViewModel

    var body: some View {
        VStack(spacing: 0) {
            TextField("Filter events…", text: $viewModel.filter.searchText)
                .textFieldStyle(.roundedBorder)
                .padding(12)

            if viewModel.filteredEvents.isEmpty {
                ContentUnavailableView(
                    viewModel.store.events.isEmpty ? "No events yet" : "No matching events",
                    systemImage: "waveform.path.ecg"
                )
            } else {
                List(selection: $viewModel.selectedEventID) {
                    ForEach(viewModel.filteredEvents) { event in
                        Button {
                            viewModel.select(event)
                        } label: {
                            HStack(spacing: 8) {
                                Text(event.timestamp, format: .dateTime.hour().minute().second())
                                    .font(.system(.caption, design: .monospaced))
                                    .frame(width: 78, alignment: .leading)

                                Circle()
                                    .fill(levelColor(event.level))
                                    .frame(width: 8, height: 8)

                                Text(event.category.rawValue.capitalized)
                                    .frame(width: 82, alignment: .leading)

                                Text(event.message)
                                    .lineLimit(1)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Text(event.durationMilliseconds.map { "\($0) ms" } ?? "—")
                                    .font(.system(.caption, design: .monospaced))
                                    .frame(width: 48, alignment: .trailing)

                                Text(event.eventID)
                                    .font(.system(.caption2, design: .monospaced))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        .buttonStyle(.plain)
                        .tag(event.id)
                    }
                }
                .listStyle(.plain)
            }
        }
    }

    private func levelColor(_ level: TelemetryLevel) -> Color {
        switch level {
        case .info:
            .blue
        case .warning:
            .orange
        case .error:
            .red
        case .debug:
            .gray
        }
    }
}

struct TelemetryEventDetailPane: View {
    let event: TelemetryEvent?

    var body: some View {
        if let event {
            List {
                Section("Event") {
                    detailRow("Message", event.message)
                    detailRow("Category", event.category.rawValue.capitalized)
                    detailRow("Source", event.source.rawValue)
                    detailRow("Event ID", event.eventID)
                    detailRow("Duration", event.durationMilliseconds.map { "\($0) ms" } ?? "—")
                    if let errorCode = event.errorCode {
                        detailRow("Error Code", errorCode)
                    }
                }

                Section("Safe Metadata") {
                    if event.metadata.isEmpty {
                        Text("No safe metadata")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(event.metadata.keys.sorted(), id: \.self) { key in
                            detailRow(key, event.metadata[key] ?? "")
                        }
                    }
                }
            }
        } else {
            ContentUnavailableView("Select an event", systemImage: "sidebar.right")
        }
    }

    @ViewBuilder
    private func detailRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.system(.caption, design: .monospaced))
        }
    }
}
