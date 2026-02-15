// ScreenTracker.swift - Automatic screen view tracking
// Copyright © 2026 One Thum Software

import Foundation

#if canImport(UIKit) && !os(watchOS)
import UIKit

/// Automatic screen tracking for UIKit apps
enum ScreenTracker {
    
    static func setupAutomaticTracking() {
        // Method swizzling for UIViewController.viewDidAppear
        swizzleViewDidAppear()
    }
    
    private static func swizzleViewDidAppear() {
        guard let originalMethod = class_getInstanceMethod(
            UIViewController.self,
            #selector(UIViewController.viewDidAppear(_:))
        ),
        let swizzledMethod = class_getInstanceMethod(
            UIViewController.self,
            #selector(UIViewController.lg_viewDidAppear(_:))
        ) else {
            return
        }
        
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}

// MARK: - UIViewController Extension

extension UIViewController {
    
    @objc func lg_viewDidAppear(_ animated: Bool) {
        // Call original implementation first (defensive)
        lg_viewDidAppear(animated)
        
        // Track screen view
        let screenName = String(describing: type(of: self))
        
        Task {
            AppStats.track(
                "screen_view",
                properties: ["screen_name": screenName]
            )
        }
    }
}

#endif

// MARK: - SwiftUI Support

#if canImport(SwiftUI)
import SwiftUI

/// SwiftUI view modifier for explicit screen tracking
public struct TrackedScreen: ViewModifier {
    let screenName: String
    
    public func body(content: Content) -> some View {
        content
            .onAppear {
                AppStats.track(
                    "screen_view",
                    properties: ["screen_name": screenName]
                )
            }
    }
}

extension View {
    /// Track when this view appears as a screen
    ///
    /// - Parameter screenName: The name of the screen
    public func trackedScreen(_ screenName: String) -> some View {
        modifier(TrackedScreen(screenName: screenName))
    }
}
#endif
