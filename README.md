# Kotel

A compass app that always points to the Western Wall in Jerusalem.

Kotel (הכותל) uses real-time GPS and device heading to calculate your bearing and distance to the Western Wall — one of the holiest sites in Judaism. Wherever you are in the world, the compass needle guides you toward the Kotel.

## Features

- **Live Compass** — Real-time directional needle pointing toward the Western Wall with smooth animations
- **Distance Display** — Shows your current distance in meters or kilometers with localized formatting
- **Dynamic Island & Live Activity** — Always-visible compass direction and distance, even when the app is backgrounded
- **Haptic Feedback** — Tactile pulses intensify as you align with the correct direction
- **Home & Lock Screen Widgets** — Glanceable compass arrow and distance on your Home or Lock Screen
- **Apple Watch** — Companion app with compass display on your wrist
- **Siri & Shortcuts** — "Hey Siri, show me Kotel" for hands-free access
- **Localized** — English, Hebrew, Yiddish, Russian, French, Spanish, German, Portuguese (BR)

## Requirements

- iOS 18.0+
- watchOS 10.0+
- Xcode 16+

## Getting Started

1. Clone the repository
   ```
   git clone https://github.com/idanmos/Kotel.git
   ```
2. Open `Kotel.xcodeproj` in Xcode
3. Select your development team under Signing & Capabilities
4. Build and run on a physical device (compass requires real hardware)

## Architecture

The app is built with SwiftUI and uses Core Location for GPS and compass heading data.

| Layer | Key Types |
|---|---|
| App | `KotelApp`, `ContentView` |
| Views | `CompassView`, `DistanceCard`, `CoordinateBar`, `PermissionView` |
| ViewModel | `CompassViewModel` |
| Services | `LocationService`, `LiveActivityService`, `HapticManager`, `SharedLocationManager` |
| Intents | `ShowDirectionIntent` |

## License

All rights reserved. © Idan Moshe
