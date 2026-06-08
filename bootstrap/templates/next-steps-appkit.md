1. Add `MacTelemetryKit` and `MacTelemetryKitUI` to your host app package or Xcode target.
2. Review `integration-snippet-appkit.txt` in this bundle and add the bootstrap call to your app delegate or startup path.
3. Attach the AppKit observer with `telemetry.attachAppKitObserver()` and retain it for the app lifetime.
4. Add `TelemetryPanelView(store: telemetry.store)` behind an internal debug window or developer-only screen.
5. Rebuild the host app and verify telemetry events with `/usr/bin/log stream` or `/usr/bin/log show`.
