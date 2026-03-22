# open-plaato-keg-ios

SwiftUI companion app for [open-plaato-keg](https://github.com/DarkJaeger/open-plaato-keg).

## Requirements
- Xcode 26.2+ (macOS 26 Tahoe compatible)
- iOS 17+
- open-plaato-keg server running on local network

## Setup
1. Clone this repo
2. Open `OpenPlaato.xcodeproj` in Xcode
3. Set your server URL in Settings tab (default: `http://192.168.8.141:8085`)
4. Build & run on simulator or device

## Features
- **Taps** — Live tap list with keg levels, temp, pouring status
- **Kegs** — Full keg details with beer info
- **Airlocks** — PLAATO airlock gravity/temp readings
- **Beverages** — Beer/beverage library
- **Settings** — Server URL override, notifications

## Architecture
- SwiftUI + `@StateObject` / `@EnvironmentObject`
- `URLSession` for REST API
- `URLSessionWebSocketTask` for live keg updates
- No external dependencies
