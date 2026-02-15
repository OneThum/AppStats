// AppInfo.swift - App metadata utilities
// Copyright © 2026 One Thum Software

import Foundation

/// Provides information about the host application
enum AppInfo {
    
    /// App version string (CFBundleShortVersionString)
    static var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
    }
    
    /// Build number (CFBundleVersion)
    static var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown"
    }
    
    /// Bundle identifier
    static var bundleID: String {
        Bundle.main.bundleIdentifier ?? "unknown"
    }
    
    /// App name (CFBundleName)
    static var name: String {
        Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "unknown"
    }
}
