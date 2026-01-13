//
//  Permissions.swift
//  TestingAX_SkyLight
//
//  Created by Aryan Rogye on 1/12/26.
//

//
//  PermissionService.swift
//  TilingWIndowManager_Test
//
//  Created by Aryan Rogye on 10/5/25.
//

@preconcurrency import Combine
@preconcurrency import ApplicationServices
@preconcurrency import AppKit

@MainActor
class PermissionService: ObservableObject {
    @Published var isAccessibilityEnabled: Bool = false
    
    var permissionService: PermissionProviding = PermissionFetcherService()
    
    init() {
        self.isAccessibilityEnabled = permissionService.getAccessibilityPermissions()
        self.requestPermission()
    }
    
    public func requestPermission() {
        permissionService.requestAccessibilityPermission()
    }
    public func openPermissionSettings() {
        permissionService.openPermissionSettings()
    }
}

@MainActor
protocol PermissionProviding {
    func getAccessibilityPermissions() -> Bool
    func openPermissionSettings()
    func requestAccessibilityPermission()
}

@MainActor
class PermissionFetcherService: PermissionProviding {
    
    func getAccessibilityPermissions() -> Bool {
        let options: CFDictionary = ["kAXTrustedCheckOptionPrompt": true] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }
    
    
    var isAccessibilityEnabled   : Bool = false
    private var pollTries: Int = 0
    
    private var pollTimer: Timer?
    private var testTap: CFMachPort?
    
    init() {
        checkAccessibilityPermission()
        
        if !isAccessibilityEnabled {
            requestAccessibilityPermission()
        }
    }
    
    // MARK: - Accessibility
    /// Check if Accessibility Permission is Granted
    func checkAccessibilityPermission() {
        let isTrusted = AXIsProcessTrusted()
        DispatchQueue.main.async {
            self.isAccessibilityEnabled = isTrusted
        }
    }
    
    func openPermissionSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }
    
    /// Request Accessibility Permissions
    func requestAccessibilityPermission() {
        let status = getAccessibilityPermissions()
        
        if !status {
            print("Accessibility permission denied.")
        } else {
            print("Accessibility permission granted.")
        }
        
        // Keep polling every second until enabled (max 10 tries)
        self.pollTries = 0
        self.pollTimer?.invalidate()
        self.pollTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            DispatchQueue.main.async {
                guard let self else {
                    timer.invalidate()
                    return
                }
                self.checkAccessibilityPermission()
                self.pollTries += 1

                if self.isAccessibilityEnabled || self.pollTries > 10 {
                    timer.invalidate()
                    self.pollTimer = nil
                }
            }
        }
    }
}

