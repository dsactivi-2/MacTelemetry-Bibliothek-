1. Add `MacTelemetryKit` and `MacTelemetryKitUI` to your host app package or Xcode target.
2. Review `integration-snippet-swiftui.txt` in this bundle and add the bootstrap call to your app entry point.
3. Add `TelemetryPanelView(store: telemetry.store)` to a debug-only surface such as settings, a debug window, or an internal panel.
4. Keep `telemetry-config-example.txt` as the starting point for your subsystem naming and category choices.
5. Rebuild the host app and verify telemetry events with `/usr/bin/log stream` or `/usr/bin/log show`.
