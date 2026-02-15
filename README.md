# AppStats SDK

The official Swift SDK for AppStats analytics.

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

Add AppStats to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/OneThum/AppStats.git", from: "1.0.0")
]
```

Or in Xcode:
1. File → Add Package Dependencies
2. Enter: `https://github.com/OneThum/AppStats.git`
3. Select version: `1.0.0` or later

## Quick Start

### 1. Configure the SDK

Initialize AppStats at your app's launch. Both approaches work equally well:

#### SwiftUI Apps

```swift
import AppStats

@main
struct MyApp: App {
    init() {
        AppStats.configure(apiKey: "as_live_xxxxxxxxxxxx")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

#### UIKit Apps

```swift
import UIKit
import AppStats

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        AppStats.configure(apiKey: "as_live_xxxxxxxxxxxx")
        return true
    }
}
```

> **Note**: Both initialization locations (`App.init()` and `AppDelegate.application(_:didFinishLaunchingWithOptions:)`) are equally valid. The SDK performs all heavy work on background threads, ensuring < 5ms impact regardless of where you initialize.

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
AppStats.track("purchase_completed", properties: [
    "product_id": "pro_annual",
    "price": 49.99,
    "currency": "USD"
])

AppStats.track("export_finished", properties: [
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
AppStats.configure(
    apiKey: "as_live_xxxxxxxxxxxx",
    autoTrackScreens: false
)

// Then manually track screens:
override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    AppStats.track("screen_view", properties: ["screen_name": "Settings"])
}
```

### User Properties

Set properties that will be included with all events:

```swift
AppStats.setUserProperty("subscription_tier", value: "pro")
AppStats.setUserProperty("theme", value: "dark")
```

### Manual Flush

Force an immediate flush of queued events:

```swift
AppStats.flush()
```

Useful in:
- `applicationWillTerminate`
- Before logging out
- After critical events

## Configuration Options

```swift
AppStats.configure(
    apiKey: "as_live_xxxxxxxxxxxx",    // Required: Your API key
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

AppStats is built with privacy as a first-class feature:

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
3. Check Xcode console for `[AppStats]` logs (debug builds only)
4. Verify the app bundle ID matches your AppStats account

### Build errors

- Ensure you're using Xcode 15+ with Swift 6.0+
- Clean build folder: `Product → Clean Build Folder`
- Delete derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData`

## FAQ

### Where should I initialize AppStats?

**Both locations work equally well:**
- **SwiftUI**: `App.init()` is the modern approach
- **UIKit**: `AppDelegate.application(_:didFinishLaunchingWithOptions:)` is the traditional approach
- **Hybrid apps**: Use whichever is clearest in your codebase

The SDK spawns all heavy work on background threads immediately, so initialization takes < 5ms regardless of location.

### Will AppStats slow down my app launch?

No. The SDK is designed for zero launch impact:
- Configuration takes < 1ms (just stores settings)
- All heavy initialization (storage, networking, crash reporting) happens on background threads
- Total overhead: < 5ms (measured with Instruments)

### What happens if my backend is down?

The SDK is resilient and handles backend issues gracefully:
- Events queue locally (up to 500 events, 10MB limit)
- Automatic retry with exponential backoff
- Circuit breaker prevents battery drain
- After 5 consecutive errors, SDK self-disables to protect your app
- **Your app will never crash due to AppStats issues**

### Can I use AppStats in multiple apps?

Yes! Each app gets its own API key. Generate a new key for each app in the AppStats dashboard.

### Does AppStats work offline?

Yes. Events are queued locally and automatically sent when connectivity is restored. Events persist for up to 48 hours.

## Support

- **Documentation**: https://docs.appstats.com
- **Dashboard**: https://app.appstats.com
- **Issues**: https://github.com/OneThum/AppStats/issues

## License

Proprietary - One Thum Software
