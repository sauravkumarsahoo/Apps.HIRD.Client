[![Android](https://github.com/clicksrv/Apps.HIRD.Client/actions/workflows/android.yml/badge.svg)](https://github.com/clicksrv/Apps.HIRD.Client/actions/workflows/android.yml) [![iOS](https://github.com/clicksrv/Apps.HIRD.Client/actions/workflows/ios.yml/badge.svg)](https://github.com/clicksrv/Apps.HIRD.Client/actions/workflows/ios.yml) [![GitHub Release](https://img.shields.io/github/v/release/clicksrv/Apps.HIRD.Client)](https://github.com/clicksrv/Apps.HIRD.Client/releases)

# HIRD Client

HIRD (HWiNFO Remote Display) Client is a Flutter mobile app for Android and iOS that streams
real-time PC hardware sensor data from the [HIRD Server](https://github.com/clicksrv/Apps.HIRD.Server/releases/)
over a local Wi-Fi network and displays it as a live-updating dashboard.

---

## Features

- **Automatic server discovery** — scans the local subnet and lists any running HIRD Server instances.
- **Live sensor dashboard** — CPU (package temp, core temps & usages, clock, power, fan),
  GPU (temp, hotspot, clocks, power), RAM (clock, load), Storage (per-device temperature),
  and System (power draw, charge level) cards that update in real time.
- **Expandable cards** — each hardware section can be expanded or collapsed individually.
- **Light / Dark theme** — toggled via an animated switcher on the server selection screen.
- **gRPC streaming** — all sensor data is transported over gRPC (Protocol Buffers) for low overhead.

---

## Requirements

| Tool | Minimum version |
|---|---|
| Flutter SDK | 2.17 (currently — upgrade to 3.x is planned) |
| Dart SDK | 2.17 |
| HIRD Server | Any release on the [server repo](https://github.com/clicksrv/Apps.HIRD.Server/releases/) |
| Network | Device and PC must be on the **same local Wi-Fi or Ethernet network** |

---

## Getting Started

```bash
# 1. Clone the repo
git clone https://github.com/clicksrv/Apps.HIRD.Client.git
cd Apps.HIRD.Client

# 2. Install dependencies
flutter pub get

# 3. Run on a connected device or emulator
flutter run
```

> **Note:** The app requires a Wi-Fi or Ethernet connection to function. It will show a
> "No Network" screen on mobile data or when offline.

### Regenerating Protobuf Code

If `protos/sensorcomms.proto` is changed, regenerate the Dart bindings by running:

```bat
generate_from_proto.bat
```

Do **not** edit files under `lib/generated/` manually.

---

## Architecture

```
Startup (main.dart)
  └─ Connectivity check
       ├─ Wi-Fi / Ethernet  →  SelectServerPage
       └─ Other             →  NoConnectivityPage

SelectServerPage
  └─ ServerScannerService (singleton, periodic LAN ping scan every 4 s)
       └─ Per discovered IP: gRPC getComputerInfo()
  └─ Tap server  →  DataVisualizerPage

DataVisualizerPage
  └─ SensorServiceClient.monitor() — gRPC server-streaming RPC
       └─ StreamBuilder<ReadingDataStream>
            ├─ CPU card    (CpuTempGauge, CpuCoreTempsWidget, CpuCoreUsagesWidget)
            ├─ GPU card    (GpuTempGauge)
            ├─ RAM card
            ├─ System card
            └─ Storage card (StorageTempGauge × N)
```

### Key Files

| File | Responsibility |
|---|---|
| `lib/main.dart` | App entry point, `GetIt` setup, connectivity guard |
| `lib/common.dart` | `ThemeData` definitions, `logger()` utility |
| `lib/constants.dart` | App name, gRPC port (`25151`) |
| `lib/settings.dart` | Singleton settings (hardcoded — no persistence yet) |
| `lib/widgets_lib.dart` | Shared layout widgets (`FloatCard`, `ExpandableFloatCard`, `CenteredColumn`, `LinearTempGauge`) |
| `lib/services/server_scanner_service.dart` | LAN discovery + `ComputerInfo` fetch |
| `lib/services/sensor_client_service.dart` | Creates a `SensorServiceClient` for a given IP |
| `lib/models/server_info.dart` | Data class holding IP, gRPC client, and `ComputerInfo` |
| `lib/pages/data_visualizer_page.dart` | Main dashboard page |
| `lib/pages/select_server_page.dart` | Server list and theme switcher |
| `protos/sensorcomms.proto` | Protobuf schema — single source of truth for all messages |

---

## Dependencies

| Package | Purpose |
|---|---|
| `grpc` | gRPC communication |
| `protobuf` | Protobuf serialisation |
| `get_it` | Service locator / dependency injection |
| `connectivity_plus` | Network state detection |
| `network_info_plus` | Device Wi-Fi IP address |
| `device_info_plus` | Device name for gRPC requests |
| `wakelock` | Screen wake-lock while viewing dashboard (**deprecated** — see roadmap) |
| `syncfusion_flutter_gauges` | Radial & linear gauge widgets (**target for replacement**) |
| `syncfusion_flutter_sliders` | Sliders (**unused** — will be removed) |
| `animated_theme_switcher` | Animated theme toggle |
| `expandable` | Expandable card panels |
| `back_button_interceptor` | Android back-button handling (**deprecated** — see roadmap) |
| `fading_edge_scrollview` | Fading scroll edges |
| `ping_discover_network` | Subnet ping scan (git dependency) |
| `freezed` / `freezed_annotation` | Immutable models (set up, not yet used) |

---

## Roadmap

### Phase 1 — Flutter 3.x Upgrade
- [ ] Raise SDK constraints to `>=3.0.0 <4.0.0` / Flutter `>=3.16.0`
- [ ] Migrate all deprecated `TextTheme` usages (`headline4` → `headlineMedium`, etc.)
- [ ] Replace `wakelock` → `wakelock_plus`
- [ ] Replace `back_button_interceptor` → `PopScope` (Flutter 3.4+)
- [ ] Update all `*_plus` packages to current versions

### Phase 2 — Remove Syncfusion
- [ ] Custom `RadialGauge` widget via `CustomPainter` (replaces `CpuTempGauge`, `GpuTempGauge`, `StorageTempGauge`)
- [ ] Custom `BarChartWidget` via `CustomPainter` (replaces `CpuCoreTempsWidget`, `CpuCoreUsagesWidget`)
- [ ] Custom `LinearRangeGauge` via `CustomPainter` (replaces `LinearTempGauge`)
- [ ] Remove `syncfusion_flutter_gauges` and `syncfusion_flutter_sliders`

### Phase 3 — Code Quality
- [ ] Split `widgets_lib.dart` into individual widget files
- [ ] Extract card build methods from `DataVisualizerPage` into standalone `StatelessWidget`s
- [ ] Make `ServerInfo` immutable (adopt `freezed`)
- [ ] Implement `Settings` persistence with `shared_preferences`
- [ ] Implement `SettingsPage` UI
- [ ] Remove dead code (`buildVisualizerDirectly`, unused `freezed` scaffolding)
- [ ] Fix color interpolation bug in `CpuCoreTempsWidget`
- [ ] Promote `sensor_client_service.dart` to a proper class

### Phase 4 — Features & UX
- [ ] Historical time-series graphs per sensor
- [ ] Per-sensor configurable thresholds
- [ ] Saved / named server list
- [ ] Improved landscape layout
- [ ] Threshold-breach notifications / alerts

---

## Contributing

1. Fork the repository and create a feature branch.
2. Follow the coding conventions in [`.github/copilot-instructions.md`](.github/copilot-instructions.md).
3. Do **not** edit files under `lib/generated/` — regenerate them with `generate_from_proto.bat`.
4. Submit a pull request with a clear description of the change.

