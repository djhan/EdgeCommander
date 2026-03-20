//
//  NSEventExtension.swift
//  EdgeCommander
//
//  Created by DJ.HAN on 3/17/26.
//

import Foundation
import Cocoa

/// NSEvent 확장
extension NSEvent {
    
    /// 지원되는 Modifiers 플래그 비트 반환
    /// - 미 지원 플래그는 제외하고 반환한다.
    /// - Returns: Command, Option, Control, Shift, Function 키 등을 포함한 `NSEvent.ModifierFlags`을 반환한다.
    func filterUnsupportModifierFlags() -> NSEvent.ModifierFlags {
        var filterdModifierFlags = NSEvent.ModifierFlags(rawValue: 0)
        if self.modifierFlags.contains(.command) {
            filterdModifierFlags.insert(.command)
        }
        if self.modifierFlags.contains(.option) {
            filterdModifierFlags.insert(.option)
        }
        if self.modifierFlags.contains(.control) {
            filterdModifierFlags.insert(.control)
        }
        if self.modifierFlags.contains(.shift) {
            filterdModifierFlags.insert(.shift)
        }
        if self.modifierFlags.contains(.function) {
            if self.keyCode.isMovementKey == false {
                filterdModifierFlags.insert(.function)
            }
            // 화살표 키, page up/down, home/end 키인 경우, function 키 입력을 무시한다
        }
        return filterdModifierFlags
    }
    
    /// Modifier 없이 Movement 키만 입력된 경우 판별
    var isOnlyMovementKey: Bool {
        if self.keyCode.isMovementKey == true,
           self.filterUnsupportModifierFlags().rawValue == 0 {
            return true
        }
        return false
    }
}

/// NSEvent 중 ModifierFlags 확장
public extension NSEvent.ModifierFlags {
    /// ModifierFlags를 Set`<Commander.Modifier>` 형식으로 변환
    /// - Important:
    ///   - 단일 키 입력시 `fn` + `numericPad` 키 조합이 같이 넘어오지만, `fn` 키만 누른 경우는 `numericPad`가 포함되지 않는다.
    ///   따라서 `fn` + `numericPad` 키가 입력되어 단일 키 입력으로 간주되는 경우에는 보조 키 플래그를 추가하지 않고 넘긴다.
    ///   - 일반적으로 뷰를 비롯한 각종 컨트롤에서 `override func performKeyEquivalent(with event: NSEvent) -> Bool` 메쏘드에서 `fn` + `numericPad` 키 조합은 false 로 반환하도록 한다.
    func toModifiers() -> Set<EdgeCommander.Modifier>? {
        
        var modifiers: Set<EdgeCommander.Modifier>?
        
        /// modifier 추가
        func addModifier(_ modifier: EdgeCommander.Modifier) {
            if modifiers == nil { modifiers = Set<EdgeCommander.Modifier>() }
            modifiers?.insert(modifier)
        }
        
        let targetModiferFlags = self.intersection(.deviceIndependentFlagsMask)
        // CapsLock 포함시
        if targetModiferFlags.contains(.capsLock) { addModifier(.capsLock) }
        // Shift 포함시
        if targetModiferFlags.contains(.shift) { addModifier(.shift) }
        // Control 포함시
        if targetModiferFlags.contains(.control) { addModifier(.control) }
        // Option 포함시
        if targetModiferFlags.contains(.option) { addModifier(.option) }
        // Command 포함시
        if targetModiferFlags.contains(.command) { addModifier(.command) }
        
        // function 과 numericPad 가 동시 입력된 경우는 등록하지 않는다
        if targetModiferFlags.contains(.function) == false ||
           targetModiferFlags.contains(.numericPad) == false {
            // Function 포함시
            if targetModiferFlags.contains(.function) { addModifier(.function) }
            // numeric pad 포함시
            if targetModiferFlags.contains(.numericPad) { addModifier(.numericPad) }
        }

        /// # help는 제외
        /*
        // help 포함시
        if targetModiferFlags.contains(.help) { addModifier(.help) }
         */

        return modifiers
    }
}
