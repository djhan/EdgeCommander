//
//  IntExtension.swift
//  EdgeCommander
//
//  Created by DJ.HAN on 3/17/26.
//

import Foundation
import Cocoa

// MARK: - Int Extension -
extension Int {
    
    /// 유니코드를 스트링으로 변환해 반환
    /// - 현재 `Int` 값이 유니코드 번호일 것으로 간주하고, [참조 링크](https://developer.apple.com/documentation/appkit/nsevent/1535851-function-key_unicodes)에 따라 스트링으로 반환한다.
    /// - Returns: 변환된 스트링을 반환하며, 실패 시에는 널값을 반환한다.
    var string: String? {
        guard let unicodeScalr = UnicodeScalar(self) else { return nil }
        return String(Character(unicodeScalr))
    }
}

// MARK: - UInt32 Extension -
extension UInt32 {
    
    /// 유니코드를 스트링으로 변환해 반환
    /// - 현재 `UInt32` 값이 유니코드 번호일 것으로 간주하고, [참조 링크](https://developer.apple.com/documentation/appkit/nsevent/1535851-function-key_unicodes)에 따라 스트링으로 반환한다.
    /// - Returns: 변환된 스트링을 반환하며, 실패 시에는 널값을 반환한다.
    var string: String? {
        guard let unicodeScalr = UnicodeScalar(self) else { return nil }
        return String(Character(unicodeScalr))
    }
    
    /// 특수 키를 표시 가능한 형태로 반환
    /// - Returns: 특수 키를 표시 가능한 스트링으로 반환하고, 특수 키가 아닌 경우에는 널값을 반환한다.
    func getSpecialKeyReadable() -> String? {
        switch (Int(self)) {
            
            // F1~F15까지
        case NSF1FunctionKey:
            return "F1"
        case NSF2FunctionKey:
            return "F2"
        case NSF3FunctionKey:
            return "F3"
        case NSF4FunctionKey:
            return "F4"
        case NSF5FunctionKey:
            return "F5"
        case NSF6FunctionKey:
            return "F6"
        case NSF7FunctionKey:
            return "F7"
        case NSF8FunctionKey:
            return "F8"
        case NSF9FunctionKey:
            return "F9"
        case NSF10FunctionKey:
            return "F10"
        case NSF11FunctionKey:
            return "F11"
        case NSF12FunctionKey:
            return "F12"
        case NSF13FunctionKey:
            return "F13"
        case NSF14FunctionKey:
            return "F14"
        case NSF15FunctionKey:
            return "F15"

            // 백스페이스 키
        case NSDeleteFunctionKey:
            return "⌫"
            // Delete 키
        case NSDeleteCharFunctionKey:
            return "⌦"
        case NSHomeFunctionKey:
            return "Home"
        case NSEndFunctionKey:
            return "End"
        case NSPageUpFunctionKey:
            return "Page Up"
        case NSPageDownFunctionKey:
            return "Page Down"
        // Clear 키
        case NSClearLineFunctionKey:
            return "Clear"
        case NSHelpFunctionKey:
            return "Help"

        // 왼쪽 화살표
        case NSLeftArrowFunctionKey:
            return "←"
        // 오른쪽 화살표
        case NSRightArrowFunctionKey:
            return "→"
        // 아래쪽 화살표
        case NSDownArrowFunctionKey:
            return "↓"
        // 위쪽 화살표
        case NSUpArrowFunctionKey:
            return "↑"

        default:
            return nil
        }
    }
}

// MARK: - UInt16 Extension -
/// UInt 16 확장
public extension UInt16 {
    
    /// 유니코드 키코드를 스트링으로 변환해 반환
    /// - Returns: 키코드 기반으로 소문자 스트링을 반환하며, 특수 키는 `CommanderKey` 형식의 스트링으로 반환한다.
    /// - Important: MenuItem의 Key 에 대응하는 스트링을 구하는 용도로 사용한다.
    var commanderKey: String? {
        switch (self) {
        case 0: return("a");
        case 1: return("s");
        case 2: return("d");
        case 3: return("f");
        case 4: return("h");
        case 5: return("g");
        case 6: return("z");
        case 7: return("x");
        case 8: return("c");
        case 9: return("v");

        case 11: return("b");
        case 12: return("q");
        case 13: return("w");
        case 14: return("e");
        case 15: return("r");
        case 16: return("y");
        case 17: return("t");
        case 18: return("1");
        case 19: return("2");
        case 20: return("3");
        case 21: return("4");
        case 22: return("6");
        case 23: return("5");
        case 24: return("=");
        case 25: return("9");
        case 26: return("7");
        case 27: return("-");
        case 28: return("8");
        case 29: return("0");
        case 30: return("]");
        case 31: return("o");
        case 32: return("u");
        case 33: return("[");
        case 34: return("i");
        case 35: return("p");
        case 36: return Commander.SpecialKey.return.rawValue
        case 37: return("l");
        case 38: return("j");
        case 39: return("'");
        case 40: return("k");
        case 41: return(";");
        case 42: return("\\");
        case 43: return(",");
        case 44: return("/");
        case 45: return("n");
        case 46: return("m");
        case 47: return(".");
        case 48: return Commander.SpecialKey.tab.rawValue
        case 49: return Commander.SpecialKey.space.rawValue
        case 50: return("`");
        // 백스페이스
        case 51: return Commander.SpecialKey.backspace.rawValue
        // Enter
        case 52: return Commander.SpecialKey.return.rawValue
        case 53: return Commander.SpecialKey.escape.rawValue

        case 65: return(".");
        case 67: return("*");
        case 69: return("+");

        // clear 키
        case 71:
            return NSClearLineFunctionKey.string
            
        case 75: return("/");
            
        // 넘패드에 있는 엔터 키
        case 76: return Commander.SpecialKey.return.rawValue
            
        case 78: return("-");
        case 81: return("=");
        case 82: return("0");
        case 83: return("1");
        case 84: return("2");
        case 85: return("3");
        case 86: return("4");
        case 87: return("5");
        case 88: return("6");
        case 89: return("7");
        case 91: return("8");
        case 92: return("9");
            
        case 96:
            return NSF5FunctionKey.string
        case 97:
            return NSF6FunctionKey.string
        case 98:
            return NSF7FunctionKey.string
        case 99:
            return NSF3FunctionKey.string
        case 100:
            return NSF8FunctionKey.string
        case 101:
            return NSF9FunctionKey.string
        case 103:
            return NSF11FunctionKey.string
        case 105:
            return NSF13FunctionKey.string
        case 107:
            return NSF14FunctionKey.string
        case 109:
            return NSF10FunctionKey.string
        case 111:
            return NSF12FunctionKey.string
        case 113:
            return NSF15FunctionKey.string
        case 114:
            return NSHelpFunctionKey.string
        case 115:
            return NSHomeFunctionKey.string
        case 116:
            return NSPageUpFunctionKey.string
        // Delete: 풀사이즈 키보드의 넘패드에 있음
        case 117:
            return Commander.SpecialKey.delete.rawValue
        case 118:
            return NSF4FunctionKey.string
        case 119:
            return NSEndFunctionKey.string
        case 120:
            return NSF2FunctionKey.string
        case 121:
            return NSPageDownFunctionKey.string
        case 122:
            return NSF1FunctionKey.string
        // 왼쪽 화살표
        case 123:
            return Commander.SpecialKey.left.rawValue
        // 오른쪽 화살표
        case 124:
            return Commander.SpecialKey.right.rawValue
        // 아래쪽 화살표
        case 125:
            return Commander.SpecialKey.down.rawValue
        // 위쪽 화살표
        case 126:
            return Commander.SpecialKey.up.rawValue
            
        default:
            return nil
        }
    }
    
    /// 이동 키 여부 반환
    /// - Returns: 화살표 키, 페이지 업/다운, 홈/엔드 키인 경우 true를 반환한다.
    var isMovementKey: Bool {
        if self == 123 ||
           self == 124 ||
           self == 125 ||
           self == 126 ||
           self == 116 ||
           self == 121 ||
           self == 115 ||
           self == 119 {
            return true
        }
        return false
    }
    
    /// 키코드 기반으로 표시용 키 스트링 반환
    /// - [참고 링크](https://stackoverflow.com/questions/9458017/convert-cgkeycode-to-character)
    /// - Returns: 키코드 기반의 표시용 키 스트링을 반환하며, 이는 MenuItem의 key를 표시하는 용도로 사용된다.
    var readable: String? {
        switch (self) {
        case 0: return("A");
        case 1: return("S");
        case 2: return("D");
        case 3: return("F");
        case 4: return("H");
        case 5: return("G");
        case 6: return("Z");
        case 7: return("X");
        case 8: return("C");
        case 9: return("V");
        // what is 10?
        case 11: return("B");
        case 12: return("Q");
        case 13: return("W");
        case 14: return("E");
        case 15: return("R");
        case 16: return("Y");
        case 17: return("T");
        case 18: return("1");
        case 19: return("2");
        case 20: return("3");
        case 21: return("4");
        case 22: return("6");
        case 23: return("5");
        case 24: return("=");
        case 25: return("9");
        case 26: return("7");
        case 27: return("-");
        case 28: return("8");
        case 29: return("0");
        case 30: return("]");
        case 31: return("O");
        case 32: return("U");
        case 33: return("[");
        case 34: return("I");
        case 35: return("P");
        case 36: return("Return");
        case 37: return("L");
        case 38: return("J");
        case 39: return("'");
        case 40: return("K");
        case 41: return(";");
        case 42: return("\\");
        case 43: return(",");
        case 44: return("/");
        case 45: return("N");
        case 46: return("M");
        case 47: return(".");
        case 48: return("Tab");
        case 49: return("Space");
        case 50: return("`");
            // 백스페이스
        case 51: return("⌫");
        case 52: return("Enter");
        case 53: return("Esc");

        case 55: return("⌘")
        case 56: return("⇧")
        case 57: return("⇪")
        case 58: return("⌥")
        case 59: return("⌃")

        case 65: return(".");
        case 67: return("*");
        case 69: return("+");
        case 71: return("Clear");
        case 75: return("/");
            
            // 넘패드에 있는 엔터 키
        case 76: return("Enter");
        case 78: return("-");
        case 81: return("=");
        case 82: return("0");
        case 83: return("1");
        case 84: return("2");
        case 85: return("3");
        case 86: return("4");
        case 87: return("5");
        case 88: return("6");
        case 89: return("7");
        case 91: return("8");
        case 92: return("9");
            
        case 96: return("F5");
        case 97: return("F6");
        case 98: return("F7");
        case 99: return("F3");
        case 100: return("F8");
        case 101: return("F9");
        case 103: return("F11");
        case 105: return("F13");
        case 107: return("F14");
        case 109: return("F10");
        case 111: return("F12");
        case 113: return("F15");
        case 114: return("Help");
        case 115: return("Home");
        case 116: return("Page Up");
            // Delete: 풀사이즈 키보드의 넘패드에 있음
        case 117: return("⌦");
        case 118: return("F4");
        case 119: return("End");
        case 120: return("F2");
        case 121: return("Page Down");
        case 122: return("F1");
            // 왼쪽 화살표
        case 123: return("←");
            // 오른쪽 화살표
        case 124: return("→");
            // 아래쪽 화살표
        case 125: return("↓");
            // 위쪽 화살표
        case 126: return("↑");
            
        default:
            return nil
        }
    }
}

