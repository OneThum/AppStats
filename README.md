# LogGobbler SDK

The official Swift SDK for LogGobbler analytics.

## Features

- 🎯 **Zero-config tracking** - Automatic screen views and lifecycle events
- 📱 **Apple-native** - Built with Swift 6, supports iOS 16+, macOS 13+, visionOS 1.0+
- 🔐 **Privacy-first** - No PII, no advertising IDs, no persistent tracking
- ⚡ **Lightweight** - < 200KB binary size, < 5ms launch impact
- 🛡️ **Crash reporting** - Automatic crash detection with symbolicated stack traces
- 🔄 **Resilient** - Offline queueing, retry logic, circuit breakers
- 🚀 **Swift 6 ready** - Full concurrency support

## Installation

### Swift Package Manager

Add LogGobbler to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/OneThum/LogGobbler.git", from: "1.0.0")
]
```

Or in Xcode:
1. File → Add Package Dependencies
2. Enter: `https://github.com/OneThum/LogGobbler.git`
3. Select version: `1.0.0` or later

## Quick Start

### 1. Configure the SDK

In your app's entry point:

```swift
import LogGobbler

@main
struct MyApp: App {
    init() {
        LogGobbler.configure(apiKey: "lg_live_xxxxxxxxxxxx")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

For UIKit apps:

```swift
import UIKit
import LogGobbler

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        LogGobbler.configure(apiKey: "lg_live_xxxxxxxxxxxx")
        return true
    }
}
```

### 2. That's it!

The SDK automatically tracks:
- ✅ App launches
- ✅ Screen views (UIKit and SwiftUI)
- ✅ App lifecycle (foreground/background)
- ✅ Crashes with stack traces
- ✅ Device and OS information

## Manual Tracking

### Custom Events

Track custom events with optional properties:

```swift
LogGobbler.track("purchase_completed", properties: [
    "product_id": "pro_annual",
    "price": 49.99,
    "currency": "USD"
])

LogGobbler.track("export_finished", properties: [
    "format": "pdf",
    "pages": 12
])
```

### Explicit Screen Tracking

For SwiftUI views, use the `.trackedScreen()` modifier:

```swift
NavigationStack {
    HomeView()
        .trackedScreen("Home")
}
```

For UIKit, disable automatic tracking and track manually:

```swift
LogGobbler.configure(
    apiKey: "lg_live_xxxxxxxxxxxx",
    autoTrackScreens: false
)

// Then manually track screens:
override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    LogGobbler.track("screen_view", properties: ["screen_name": "Settings"])
}
```

### User Properties

Set properties that will be included with all events:

```swift
LogGobbler.setUserProperty("subscription_tier", value: "pro")
LogGobbler.setUserProperty("theme", value: "dark")
```

### Manual Flush

Force an immediate flush of queued events:

```swift
LogGobbler.flush()
```

Useful in:
- `applicationWillTerminate`
- Before logging out
- After critical events

## Configuration Options

```swift
LogGobbler.configure(
    apiKey: "lg_live_xxxxxxxxxxxx",    // Required: Your API key
    autoTrackScreens: true,             // Optional: Auto-track screen views (default: true)
    flushInterval: 30                   // Optional: Flush interval in seconds (default: 30)
)
```

## What Gets Tracked

### Automatic Events

| Event Type | Trigger | Data Captured |
|------------|---------|---------------|
| `app_launch` | App starts | Cold/warm launch, version, build, device info |
| `screen_view` | View appears | Screen name, timestamp |
| `app_background` | App backgrounds | Session duration, screen count |
| `app_foreground` | App foregrounds | Time in background |
| `crash` | Signal/exception | Stack trace, device state, memory |

### Device Information

Automatically included with all events:
- Device model (e.g., "iPhone15,2")
- OS version
- App version and build number
- SDK version
- Locale and timezone
- Screen resolution

### What's NOT Tracked

- ❌ No IDFA or IDFV
- ❌ No persistent user IDs
- ❌ No PII (names, emails, etc.)
- ❌ No location permissions required
- ❌ No third-party trackers

## Performance

The SDK is designed to have **zero impact** on your app:

- **Binary size**: < 200KB
- **Launch time**: < 5ms
- **Memory**: < 2MB peak
- **Network**: 1-5KB per flush (gzip compressed)
- **CPU**: < 1% sustained
- **Main thread**: 0ms (all work happens on background queue)

## Resilience

The SDK follows strict defensive programming principles:

- ✅ Never crashes the host app
- ✅ Graceful degradation on errors
- ✅ Offline event queueing (up to 10MB)
- ✅ Automatic retry with exponential backoff
- ✅ Circuit breaker for network failures
- ✅ Kill switch after repeated errors

## Privacy

LogGobbler is built with privacy as a first-class feature:

- **No tracking across apps**: Each session gets a random UUID
- **IP-based geolocation only**: City-level precision, processed server-side
- **No ad tracking**: Compatible with ATT, doesn't trigger prompts
- **No user profiles**: Events are anonymous
- **GDPR/CCPA friendly**: No personal data collection

## Requirements

- iOS 16.0+ / macOS 13.0+ / visionOS 1.0+
- Swift 6.0+
- Xcode 15.0+

## Troubleshooting

### Events not appearing in dashboard

1. Check your API key is correct
2. Ensure you have network connectivity
3. Check Xcode console for `[LogGobbler]` logs (debug builds only)
4. Verify the app bundle ID matches your LogGobbler account

### Build errors

- Ensure you're using Xcode 15+ with Swift 6.0+
- Clean build folder: `Product → Clean Build Folder`
- Delete derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData`

## Support

- **Documentation**: https://docs.loggobbler.com
- **Dashboard**: https://app.loggobbler.com
- **Issues**: https://github.com/OneThum/LogGobbler/issues

## License

Proprietary - One Thum Software
