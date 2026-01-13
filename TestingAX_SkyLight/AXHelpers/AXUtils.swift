//
//  AXUtils.swift
//  TestingAX_SkyLight
//
//  Created by Aryan Rogye on 1/12/26.
//

@preconcurrency import Cocoa

@objcMembers
public class AXUtils: NSObject {
    
    @objc
    public static func __AXUIElementGetWindow(
        _ element: AXUIElement,
        _ outWindowID: UnsafeMutablePointer<CGWindowID>?
    ) -> AXError {
        return _AXUIElementGetWindow(element, outWindowID)
    }
    
    @objc
    public static func __AXUIElementCreateWithRemoteToken(
        _ token: CFData,
    ) -> Unmanaged<AXUIElement>? {
        return _AXUIElementCreateWithRemoteToken(token)
    }
    
//    @_silgen_name("_AXUIElementCreateWithRemoteToken")
//    func _AXUIElementCreateWithRemoteToken(
//        _ token: CFData
//    ) -> Unmanaged<AXUIElement>?

    
    @objc
    public static func findMatchingAXWindow(
        pid: pid_t,
        targetCGSFrame: CGRect,
    ) -> AXUIElement? {
        
        let appAX = AXUIElementCreateApplication(pid)
        
        var windowsRef: AnyObject?
        guard AXUIElementCopyAttributeValue(appAX, kAXWindowsAttribute as CFString, &windowsRef) == .success
        else { return nil }
        
        let axTargetRect = AXUtils().cgToAXRect(targetCGSFrame)
        let tol: CGFloat = 12.0 // be generous; titles/shadows/scale can skew a bit
        
        for ax in AXUIElement.windowsByBruteForce(pid) {
            if let axRect = getAXWindowRect(ax),
               axRect.width >= 5, axRect.height >= 5,
               AXUtils().rectRoughMatch(axRect, axTargetRect, tol: tol) {
                return ax
            }
        }
        
        return nil
    }
    
    private func cgToAXRect(_ cg: CGRect) -> CGRect {
        // Pick the screen that contains the CG rect
        let screen = NSScreen.screens.first { $0.frame.intersects(cg) } ?? NSScreen.main!
        // Flip Y: CG uses a different origin than AX
        let flippedY = screen.frame.maxY - (cg.origin.y + cg.size.height)
        return CGRect(x: cg.origin.x, y: flippedY, width: cg.size.width, height: cg.size.height)
    }
    
    private func nearlyEqual(_ a: CGFloat, _ b: CGFloat, tol: CGFloat) -> Bool {
        abs(a - b) <= tol
    }
    
    private func rectRoughMatch(_ a: CGRect, _ b: CGRect, tol: CGFloat) -> Bool {
        nearlyEqual(a.origin.x, b.origin.x, tol: tol)
        && nearlyEqual(a.origin.y, b.origin.y, tol: tol)
        && nearlyEqual(a.size.width, b.size.width, tol: tol)
        && nearlyEqual(a.size.height, b.size.height, tol: tol)
    }
    
    
    private static func isValidAXWindowCandidate(_ axWindow: AXUIElement) -> Bool {
        var roleRef: AnyObject?
        guard AXUIElementCopyAttributeValue(axWindow, kAXRoleAttribute as CFString, &roleRef) == .success,
              let role = roleRef as? String, role == kAXWindowRole as String else {
            return false
        }
        
        var subroleRef: AnyObject?
        if AXUIElementCopyAttributeValue(axWindow, kAXSubroleAttribute as CFString, &subroleRef) == .success {
            if let subrole = subroleRef as? String,
               ![kAXStandardWindowSubrole as String, kAXDialogSubrole as String].contains(subrole) {
                return false
            }
        }
        
        guard let rect = getAXWindowRect(axWindow),
              rect.width >= 100, rect.height >= 100,
              rect.origin.x.isFinite, rect.origin.y.isFinite
        else {
            return false
        }
        
        return true
    }
    
    private static func getAXWindowRect(_ axWindow: AXUIElement) -> CGRect? {
        var positionRef: AnyObject?
        var sizeRef: AnyObject?
        guard AXUIElementCopyAttributeValue(axWindow, kAXPositionAttribute as CFString, &positionRef) == .success,
              AXUIElementCopyAttributeValue(axWindow, kAXSizeAttribute as CFString, &sizeRef) == .success
        else { return nil }
        
        var cgPoint: CGPoint = .zero
        var cgSize: CGSize = .zero
        AXValueGetValue(positionRef as! AXValue, .cgPoint, &cgPoint)
        AXValueGetValue(sizeRef as! AXValue, .cgSize, &cgSize)
        
        guard cgSize.width > 50 && cgSize.height > 50 else { return nil }
        return CGRect(origin: cgPoint, size: cgSize)
    }
}




//
//  AXHelpers.swift
//  ComfyTile
//  Copyright (C) 2025 Aryan Rogye
//  SPDX-License-Identifier: GPL-3.0-or-later
//  Derived from DockDoor (GPL-3.0) and/or alt-tab-macos (GPL); modified by Aryan Rogye.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.

import ApplicationServices
import Cocoa

extension AXValue {
    func toValue<T>() -> T? {
        let pointer = UnsafeMutablePointer<T>.allocate(capacity: 1)
        let success = AXValueGetValue(self, AXValueGetType(self), pointer)
        let value = pointer.pointee
        pointer.deallocate()
        return success ? value : nil
    }
    
    static func from<T>(value: T, type: AXValueType) -> AXValue? {
        var value = value
        return withUnsafePointer(to: &value) { valuePointer in
            AXValueCreate(type, valuePointer)
        }
    }
}

/// Stripped out version from DockDoor
extension AXUIElement {
    func axCallWhichCanThrow<T>(_ result: AXError, _ successValue: inout T) throws -> T? {
        switch result {
        case .success: return successValue
            // .cannotComplete can happen if the app is unresponsive; we throw in that case to retry until the call succeeds
        case .cannotComplete: throw AxError.runtimeError
            // for other errors it's pointless to retry
        default: return nil
        }
    }
    
    func getValue(_ attribute: NSAccessibility.Attribute) -> AnyObject? {
        var value: AnyObject?
        let result = AXUIElementCopyAttributeValue(self, attribute.rawValue as CFString, &value)
        guard result == .success else { return nil }
        return value
    }
    
    private func setWrappedValue<T>(_ attribute: NSAccessibility.Attribute, _ value: T, _ type: AXValueType) {
        guard let value = AXValue.from(value: value, type: type) else { return }
        setValue(attribute, value)
    }
    
    func setValue(_ attribute: NSAccessibility.Attribute, _ value: CGPoint) {
        setWrappedValue(attribute, value, .cgPoint)
    }
    
    func setValue(_ attribute: NSAccessibility.Attribute, _ value: CGSize) {
        setWrappedValue(attribute, value, .cgSize)
    }
    
    func setValue(_ attribute: NSAccessibility.Attribute, _ value: AnyObject) {
        AXUIElementSetAttributeValue(self, attribute.rawValue as CFString, value)
    }
    
    
    func getWrappedValue<T>(_ attribute: NSAccessibility.Attribute) -> T? {
        guard let value = getValue(attribute), CFGetTypeID(value) == AXValueGetTypeID() else { return nil }
        return (value as! AXValue).toValue()
    }
    
    func attribute<T>(_ key: String, _ _: T.Type) throws -> T? {
        var value: AnyObject?
        return try axCallWhichCanThrow(AXUIElementCopyAttributeValue(self, key as CFString, &value), &value) as? T
    }
    
    static func windowsByBruteForce(_ pid: pid_t) -> [AXUIElement] {
        var token = Data(count: 20)
        token.replaceSubrange(0 ..< 4, with: withUnsafeBytes(of: pid) { Data($0) })
        token.replaceSubrange(4 ..< 8, with: withUnsafeBytes(of: Int32(0)) { Data($0) })
        token.replaceSubrange(8 ..< 12, with: withUnsafeBytes(of: Int32(0x636F_636F)) { Data($0) })
        
        var results: [AXUIElement] = []
        for axId: AXUIElementID in 0 ..< 1000 {
            token.replaceSubrange(12 ..< 20, with: withUnsafeBytes(of: axId) { Data($0) })
            if let el = _AXUIElementCreateWithRemoteToken(token as CFData)?.takeRetainedValue(),
               let subrole = try? el.subrole(),
               [kAXStandardWindowSubrole, kAXDialogSubrole].contains(subrole)
            {
                results.append(el)
            }
        }
        return results
    }
    
    func _cgWindowID() -> CGWindowID? {
        var id: CGWindowID = 0
        let err = _AXUIElementGetWindow(self, &id)
        guard err == .success, id != 0 else { return nil }
        return id
    }
    
    func title() throws -> String? {
        try attribute(kAXTitleAttribute, String.self)
    }
    
    func isMinimized() throws -> Bool {
        let result = try attribute(kAXMinimizedAttribute, Bool.self) == true
        return result
    }
    
    func subrole() throws -> String? {
        try attribute(kAXSubroleAttribute, String.self)
    }
}

enum AxError: Error {
    case runtimeError
}

typealias AXUIElementID = UInt64

@_silgen_name("_AXUIElementGetWindow")
func _AXUIElementGetWindow(
    _ element: AXUIElement,
    _ outWindowID: UnsafeMutablePointer<CGWindowID>?
) -> AXError

@_silgen_name("_AXUIElementCreateWithRemoteToken")
func _AXUIElementCreateWithRemoteToken(
    _ token: CFData
) -> Unmanaged<AXUIElement>?


let kAXFullscreenAttribute = "AXFullScreen"
let kAXWindowNumberAttribute = "AXWindowNumber" as CFString
