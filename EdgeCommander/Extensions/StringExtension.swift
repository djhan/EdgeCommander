//
//  StringExtension.swift
//  EdgeCommander
//
//  Created by DJ.HAN on 3/17/26.
//

import Foundation

// MARK: - Extensions for Commander -
public extension String {
    
    /// Special 키 여부 반환
    var isSpecialKey: Bool {
        guard self.specialKey != nil else {
            return false
        }
        return true
    }
    /// 단축키 전환 방향
    /// - 현재 스트링의 유니코드 값이 `EdgeCommander.Special` 키인 경우, 전환 방향을 반환한다. 일반 키라면 널값을 반환한다.
    var axis: Commander.Axis? {
        guard let specialKey = self.specialKey else {
            return nil
        }
        switch specialKey {
            // 수평
        case .left, .right:
            return .horizontal
            // 수직
        case .up, .down, .home, .end, .pageUp, .pageDown:
            return .vertical
            // 그 외 - 선택용 키
        default:
            return Commander.Axis.none
        }
    }
    
    /// `Commander.Special` 값을 반환
    /// - Returns: 현재 스트링의 유니코드 값이 백스페이스, 탭, 리턴, 이스케이프, 상하좌우, 삭제, 홈, 엔드, 페이지업, 페이지다운 키인 경우, Commander.SpecialKey 값을 반환한다.
    /// 일반 키라면 널값을 반환한다.
    var specialKey: Commander.SpecialKey? {
        let filtered = Commander.SpecialKey.allCases.filter {
            if $0.rawValue == self {
                return true
            }
            // 유니코드 기반으로 special 키 여부 확인
            if let unicode = UnicodeScalar(self)?.value,
               let specialKeyReadable = unicode.specialKeyReadable(),
               // specialKey의 readable 값과 직접 비교
               // $0.rawValue 의 readable 값과 비교하면 무한 루프에 빠질 수 있으니 주의!
                $0.readable == specialKeyReadable {
                return true
            }
            return false
        }
        if filtered.count > 0 {
            return filtered.first
        }
        return nil
    }
    
    /// 표시 가능한 형태로 반환
    /// - Returns: 현재 스트링의 유니코드 값이 `Commander.Special` 키의 경우, 표시 가능한 형태로 반환한다.
    /// 일반 키라면 대문자로 반환한다.
    var readable: String {
        // Commander Special 키 포함시, Commander 에 정의된 readble 형태로 반환
        if let specialKey = self.specialKey {
            return specialKey.readable
        }
        // 유니코드 기반으로 Special 키인지 확인
        guard let unicode = UnicodeScalar(self)?.value,
              let specialKeyReadable = unicode.specialKeyReadable() else {
            // 일반 캐릭터인 경우 대문자 반환
            return self.uppercased()
        }
        // 표시 가능한 Special 키 반환
        return specialKeyReadable
    }
}

// MARK: - KeyCode -
/// 스트링: 키코드 딕셔너리 배열
/// - [참고 링크](https://github.com/pselle/macvimspeak/blob/master/MacVimSpeak/KeyCode.swift)
public let KeyCode: [String:UInt16] = [
    "A"                    : 0x00,
    "S"                    : 0x01,
    "D"                    : 0x02,
    "F"                    : 0x03,
    "H"                    : 0x04,
    "G"                    : 0x05,
    "Z"                    : 0x06,
    "X"                    : 0x07,
    "C"                    : 0x08,
    "V"                    : 0x09,
    "B"                    : 0x0B,
    "Q"                    : 0x0C,
    "W"                    : 0x0D,
    "E"                    : 0x0E,
    "R"                    : 0x0F,
    "Y"                    : 0x10,
    "T"                    : 0x11,
    "1"                    : 0x12,
    "2"                    : 0x13,
    "3"                    : 0x14,
    "4"                    : 0x15,
    "5"                    : 0x17,
    "6"                    : 0x16,
    "="                    : 0x18,
    "9"                    : 0x19,
    "7"                    : 0x1A,
    "-"                    : 0x1B,
    "8"                    : 0x1C,
    "0"                    : 0x1D,
    "]"                    : 0x1E,
    "O"                    : 0x1F,
    "U"                    : 0x20,
    "["                    : 0x21,
    "I"                    : 0x22,
    "P"                    : 0x23,
    "L"                    : 0x25,
    "J"                    : 0x26,
    "\""                   : 0x27,
    "K"                    : 0x28,
    ";"                    : 0x29,
    "\\"                   : 0x2A,
    ","                    : 0x2B,
    "/"                    : 0x2C,
    "N"                    : 0x2D,
    "M"                    : 0x2E,
    "."                    : 0x2F,
    "Grave"                : 0x32,
    "KeypadDecimal"        : 0x41,
    "KeypadMultiply"       : 0x43,
    "KeypadPlus"           : 0x45,
    "KeypadClear"          : 0x47,
    "KeypadDivide"         : 0x4B,
    "KeypadEnter"          : 0x4C,
    "KeypadMinus"          : 0x4E,
    "KeypadEquals"         : 0x51,
    "Keypad0"              : 0x52,
    "Keypad1"              : 0x53,
    "Keypad2"              : 0x54,
    "Keypad3"              : 0x55,
    "Keypad4"              : 0x56,
    "Keypad5"              : 0x57,
    "Keypad6"              : 0x58,
    "Keypad7"              : 0x59,
    "Keypad8"              : 0x5B,
    "Keypad9"              : 0x5C,
    
    /* keycodes for keys that are independent of keyboard layout*/
    "Return"                    : 0x24,
    "Tab"                       : 0x30,
    "Space"                     : 0x31,
    "Delete"                    : 0x33,
    "Escape"                    : 0x35,
    "Command"                   : 0x37,
    "Shift"                     : 0x38,
    "CapsLock"                  : 0x39,
    "Option"                    : 0x3A,
    "Control"                   : 0x3B,
    "RightShift"                : 0x3C,
    "RightOption"               : 0x3D,
    "RightControl"              : 0x3E,
    "Function"                  : 0x3F,
    "F17"                       : 0x40,
    "VolumeUp"                  : 0x48,
    "VolumeDown"                : 0x49,
    "Mute"                      : 0x4A,
    "F18"                       : 0x4F,
    "F19"                       : 0x50,
    "F20"                       : 0x5A,
    "F5"                        : 0x60,
    "F6"                        : 0x61,
    "F7"                        : 0x62,
    "F3"                        : 0x63,
    "F8"                        : 0x64,
    "F9"                        : 0x65,
    "F11"                       : 0x67,
    "F13"                       : 0x69,
    "F16"                       : 0x6A,
    "F14"                       : 0x6B,
    "F10"                       : 0x6D,
    "F12"                       : 0x6F,
    "F15"                       : 0x71,
    "Help"                      : 0x72,
    "Home"                      : 0x73,
    "PageUp"                    : 0x74,
    "ForwardDelete"             : 0x75,
    "F4"                        : 0x76,
    "End"                       : 0x77,
    "F2"                        : 0x78,
    "PageDown"                  : 0x79,
    "F1"                        : 0x7A,
    "LeftArrow"                 : 0x7B,
    "RightArrow"                : 0x7C,
    "DownArrow"                 : 0x7D,
    "UpArrow"                   : 0x7E,
    
    // The following were discovered using the Key Codes app
    "Backspace"                 : 0x33,
    "Enter"                     : 0x24,
    "<"                         : 0x2B,
    ">"                         : 0x2F,
    "{"                         : 0x21,
    "}"                         : 0x1E,
    ")"                         : 0x1D,
    "("                         : 0x19,
    "!"                         : 0x12,
    "|"                         : 0x2A,
    ":"                         : 0x29,
    "`"                         : 0x32,
    "'"                         : 0x27,
    "&"                         : 0x1A,
    "%"                         : 0x17,
    "?"                         : 0x2C,
    "*"                         : 0x1C,
    "~"                         : 0x32,
    "@"                         : 0x13,
    "$"                         : 0x15,
    "^"                         : 0x16,
    "+"                         : 0x18,
    "#"                         : 0x14,
    
    // I"SO" keyboards only
    "Section"               : 0x0A,
    
    // J"IS" keyboards only
    "Yen"                   : 0x5D,
    "_"                     : 0x5E,
    "KeypadComma"           : 0x5F,
    "Eisu"                  : 0x66,
    "Kana"                  : 0x68
]
