# MarketWire

MarketWire is a native SwiftUI app for following realtime crypto market data from public WebSocket feeds.

The app focuses on live market state, connection health, favorites, local alerts, and a clean adaptive interface for iPhone and iPad.

## Overview

- Favorites-based watchlist
- Searchable market catalog
- Live asset detail with ticker, trades, chart, and compact order book
- Local price alerts
- SwiftData-backed local cache
- Opt-in Face ID app lock
- Accessible, adaptive SwiftUI interface

## Stack

- SwiftUI
- TCA
- Swift Concurrency
- Native `URLSessionWebSocketTask`
- SwiftData
- `NavigationSplitView`
- iOS 17 minimum
- iOS 26 Liquid Glass enhancements where available

## Development

```sh
swiftlint
xcodebuild -scheme MarketWire -destination 'platform=iOS Simulator,name=iPhone 16' build
xcodebuild -scheme MarketWire -destination 'platform=iOS Simulator,name=iPhone 16' test
```
