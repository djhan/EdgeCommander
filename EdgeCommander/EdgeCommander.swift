//
//  EdgeCommander.swift
//  EdgeCommander
//
//  Created by DJ.HAN on 3/17/26.
//

import Foundation
import Cocoa

import EdgeCommonLib

// MARK: - Typealias -

/// EdgeCommander 검색 결과
/// - Parameters:
///   - commander: EdgeCommander
///   - category: EdgeCommander.Category 열거형. normal 과 swap 중 양자택일
typealias FoundCommander = (commander: EdgeCommander, category: EdgeCommander.Category)


// MARK: - EdgeCommander Class -

/// EdgeCommander Class
/// - NSMenuItem의 단축키를 능동적으로 관리하는 객체.
/// - 내부적으로 3 종류의 단축키를 격납할 수 있다.
///   1. 기본 단축키: 일반적인 단축키.
///   2. 방향 전환 단축키: 좌우 또는 상하로 이미지 표시 방향이 바뀐 경우에 사용되는 단축키.
///   3. 대체 단축키: 특수한 상황에서 사용되는 단축키로, 보조 키만 대체하여 사용한다.
/// - Important: 메인 쓰레드에서 실행하기 위해 @MainActor 매크로를 추가한다.
@MainActor
public class EdgeCommander: Codable,
                            NSCopying,
                            Identifiable,
                            Hashable {
    
    // MARK: - Static Method for Making Shortcut String
    /// 특정 Key과 Modifiers 조합으로 단축키 스트링을 생성하는 Static 메쏘드
    /// - Parameters:
    ///   - modifiers: `Commander.Modifier`로 보조 키 셋을 지정한다. 널값을 지정할 수 있다.
    ///   - key: 키 값을 지정한다. 널값을 지정할 수 있다.
    /// - Returns: 메뉴아이템에 표시될 단축키 스트링을 반환한다. 보조 키/ 키 값이 주어지지 않으면 빈 문자열을 반환한다.
    static internal func shortcutReadable(modifiers: Set<EdgeCommander.Modifier>?, key: String?) -> String {
        // key 값이 주어졌는지 확인
        // Modifiers는 없을 수도 있다
        guard let key = key else {
            // 빈 문자열 반환
            return ""
        }
        return autoreleasepool { () -> String in
            var shortcutReadable = String()
            
            // set 특성상 편집 키 순서가 제멋대로 표시될 수 있기 때문에 편집 키를 순서대로 표시할 수 있도록 한다
            
            /// 특정 EdgeCommander 보조 키의 읽기 가능한 문자열을 추가하는 내부 메쏘드
            func addModifier(_ modifier: EdgeCommander.Modifier) {
                shortcutReadable.append(modifier.rawValue)
            }
            
            if let modifiers = modifiers {
                if modifiers.contains(.command)     { addModifier(.command) }
                if modifiers.contains(.option)      { addModifier(.option) }
                if modifiers.contains(.control)     { addModifier(.control) }
                if modifiers.contains(.shift)       { addModifier(.shift) }
                if modifiers.contains(.function)    { addModifier(.function) }
                if modifiers.contains(.capsLock)    { addModifier(.capsLock) }
            }
            
            if key.count > 0 {
                // 특수 단축키가 있는 경우
                if shortcutReadable.count > 0 {
                    // key 값이 special 키 값인 경우, 표시 가능한 형태로 전환
                    // 마지막으로 키 추가
                    shortcutReadable = shortcutReadable + " " + key.readable
                }
                // 단일 키만 있는 경우
                else {
                    shortcutReadable = key.readable
                }
            }
            
            guard shortcutReadable.count > 0 else { return "" }
            // 단축키 조합의 표시 가능한 문자열 반환
            return shortcutReadable
        }
    }
    
    // MARK: - Enumerations
    
    /// 보조 키 스트링
    public enum Modifier: String, Codable {
        /// CapsLock
        case capsLock   = "⇪"
        /// Shift
        case shift      = "⇧"
        /// Control
        case control    = "⌃"
        /// Option
        case option     = "⌥"
        /// Command
        case command    = "⌘"
        /// NumericPad
        case numericPad = "num"
        /// Help
        case help       = "help"
        /// Function
        case function   = "fn"
    }
    /// 특수 키 스트링
    /// - [참고 링크](https://cool8jay.github.io/shortcut-nemenuitem-nsbutton/)에 포함된 백스페이스, 탭, 리턴, 이스케이프, 상하좌우, 삭제, 홈, 엔드, 페이지업, 페이지다운 키.
    /// - CaseIterable 프로토콜에 대응해 allCases로 배열처럼 사용할 수 있도록 한다
    public enum SpecialKey: String, CaseIterable {
        case backspace  = "\u{08}"
        case tab        = "\u{09}"
        case `return`   = "\u{0d}"
        case escape     = "\u{1b}"
        // sonoma 대응용으로 코드값을 수정
        // 소용없는 걸로 보여 롤백 처리
        case left       = "\u{1c}" //"\u{f702}"
        case right      = "\u{1d}" //"\u{f703}"
        case up         = "\u{1e}"
        case down       = "\u{1f}"
        case space      = "\u{20}"
        case delete     = "\u{7f}"
        case home       = "\u{2196}"
        case end        = "\u{2198}"
        case pageUp     = "\u{21de}"
        case pageDown   = "\u{21df}"
        
        /// 표시 가능한 형태로 반환
        public var readable: String {
            switch self {
            case .backspace:
                return "⌫"
            case .tab:
                return "Tab"
            case .return:
                return "Return"
            case .escape:
                return "Esc"
            case .left:
                return "←"
            case .right:
                return "→"
            case .up:
                return "↑"
            case .down:
                return "↓"
            case .space:
                return "Space"
            case .delete:
                return "⌦"
            case .home:
                return "Home"
            case .end:
                return "End"
            case .pageUp:
                return "Page Up"
            case .pageDown:
                return "Page Down"
            }
        }
    }
    /// 단축키 종류
    public enum Category {
        /// 일반 단축키
        case normal
        /// 방향 전환 단축키
        case swap
        /// 대체 단축키
        case alternative
    }
    /// 단축키 전환 방향
    /// - 이미지 표시 방향을 기준으로 단축키를 전환한다.
    /// - Codable 대응을 위해 Int 형태로 선언한다.
    public enum Axis: Int, Codable {
        /// 없음
        case none
        /// 수평 전환 (좌/우)
        case horizontal
        /// 수직 전환 (위/아래)
        case vertical
    }
    /// Label
    /// - 테이블 뷰 Identifier 및 헤더에 사용되는 라벨
    public enum Label: String {
        /// Preference 키값
        case preference     = "userShortcut"
        /// 메인 메뉴
        case mainMenu       = "MainMenu"
        /// 타이틀
        case title          = "Title"
        /// 단축키
        case shortcut       = "Shortcut"
        /// 방향 전환 단축키
        case swapKey        = "SwapKey"
        /// 방향 전환 가능 여부
        case canSwap        = "CanSwap"
        /// 대체 단축키
        case alternative    = "Alternative"
    }
    /// CodingKeys
    public enum CodingKeys: String, CodingKey {
        case isRoot         = "isRoot"
        case title          = "title"
        case action         = "action"
        case tag            = "tag"
        case key            = "key"
        case canSwap        = "canSwap"
        case swapDirection  = "swapDirection"
        case swapKey        = "swapKey"
        case modifiers      = "modifiers"
        case swapTitle      = "swapTitle"
        case alterKey       = "alternativeKey"
        case alterModifiers = "alternativeModifiers"
        case alterTitle     = "alternativeTitle"
        case children       = "children"
    }
    
    // MARK: - Properties
    
    /// ID
    public let id = UUID()

    /// 최상위 Root EdgeCommander 여부
    var isRoot: Bool = false
    /// 하위 EdgeCommander 아이템 배열
    var children: [EdgeCommander]?
    /// leaf 노드 여부
    var isLeaf: Bool {
        return !isParent
    }
    /// Parent 메뉴아이템 여부
    var isParent: Bool {
        return menu != nil || children != nil
    }
    
    /// 메뉴 아이템
    weak var menuItem: NSMenuItem?
    /// 메뉴 아이템 태그
    var tag: Int = 0
    
    /// 상하/좌우 전환시 바꿔치기 대응 여부
    var canSwap: Bool = false
    /// 상하/좌우 전환 여부
    var isSwap = false
    /// 실제 상하/좌우 전환 가능 여부
    /// - canSwap = true인 상황에서 swapKey가 주어졌는지 확인
    var shouldSwap: Bool {
        return canSwap && swapKey != nil
    }
    
    /// 전환 방향
    private var swapAxis: EdgeCommander.Axis = .none
    
    /// 메인 메뉴
    /// - Root EdgeCommander/SubMenu EdgeCommander 전용 메뉴
    private weak var menu: NSMenu?
    
    /// 메뉴명 프로퍼티
    var title: String {
        didSet {
            if self.menuItem?.title != self.title {
                self.menuItem?.title = self.title
            }
        }
    }
    /// selector 프로퍼티
    /// - 실제 실행될 액션을 격납하는 프로퍼티.
    var action: Selector? {
        didSet {
            // action description을 업데이트한다
            self.actionDescription = self.action?.description
        }
    }
    
    /// action description
    /// - selector 설정 시, 해당 action의 description이 지정된다.
    var actionDescription: String?
    /// 타겟
    /// - action의 실행 타겟으로 미 지정 시에는 First Responder가 타겟이 된다.
    var target: AnyObject? {
        didSet {
            self.menuItem?.target = target
        }
    }
    /// 입력 키 값
    var key: String? {
        didSet {
            // 기존 값과 동일한지 확인
            guard oldValue != self.key else {
                return
            }
            // 단축키 업데이트
            self.updateShortcut()
        }
    }
    /// 방향 전환 단축키
    var swapKey: String? {
        didSet {
            // 기존 값과 동일한지 확인
            guard oldValue != self.swapKey else {
                return
            }
            // 방향 전환 상태인 경우, 단축키 업데이트를 실행한다.
            if self.isSwap == true {
                // 단축키 업데이트
                self.updateShortcut()
            }
            else {
                // 문자열만 업데이트한다.
                self.updateShortcutReadables()
            }
        }
    }
    /// 방향 전환 시 메뉴명
    var swapTitle: String?
    
    /// 보조 키 셋 프로퍼티
    /// - Command, Option, Control 등 보조 키 값을 격납하는 셋.
    var modifiers: Set<Modifier>? {
        didSet {
            // 기존 값과 동일한지 확인
            guard oldValue != self.modifiers else {
                return
            }
            // 단축키 업데이트
            self.updateShortcut()
        }
    }
    /// 현재 지정된 보조 키의 `NSEvent.ModifierFlags` 프로퍼티
    var modifierFlags: NSEvent.ModifierFlags {
        return EdgeCommander.convert(modifiers: self.modifiers)
    }
    /// 현재 메뉴아이템에 적용된 편집 키 셋
    /// - Command, Option, Control 등 편집 키 값
    private var currentModifiers: Set<Modifier>? { self.menuItem?.keyEquivalentModifierMask.toModifiers() }
    
    /// 단축키 표시 전용 스트링
    /// - 편집 키 셋과 입력 키 값을 조합해 구성된 프로퍼티.
    var shortcutReadable: String?
    
    /// 이동용 키 포함 여부
    /// - 화살표, page up/down, home, end 등 이동용 키를 포함했는지 여부를 판정하는 프로퍼티.
    var hasMovableKey: Bool {
        guard let key = self.key else { return false }
        switch key.readable {
        case EdgeCommander.SpecialKey.up.readable,
            EdgeCommander.SpecialKey.down.readable,
            EdgeCommander.SpecialKey.left.readable,
            EdgeCommander.SpecialKey.right.readable,
            EdgeCommander.SpecialKey.pageUp.readable,
            EdgeCommander.SpecialKey.pageDown.readable,
            EdgeCommander.SpecialKey.home.readable,
            EdgeCommander.SpecialKey.end.readable:
            return true
        default:
            return false
        }
    }
    /// 이동용 키로만 구성되었는지 여부
    /// - 화살표, page up/down, home, end 등 이동용 키로만 이뤄졌는지 여부를 판정하는 프로퍼티.
    var isOnlyMovableKey: Bool {
        // modifiers 갯수가 1개 이상이면 false 반환
        guard self.modifiers?.count ?? 0 == 0 else { return false }
        return self.hasMovableKey
    }
    
    /// ** Alternative Key 관련 프로퍼티 **
    
    /// 대체 단축키 사용 가능 여부
    /// - 특수 키(SpecialKey) 단독 사용 시에 true를 반환한다.
    var canAlternative: Bool {
        // 최상위 Root EdgeCommander는 하위 EdgeCommander 변경이 가능하도록 true 를 반환한다.
        if self.isRoot == true { return true }
        // 하위 chidren이 있는 경우도 true 를 반환한다.
        if let children = self.children, children.count > 0 { return true }
        
        // 이미 modifiers가 있고 갯수가 0개 이상인 경우에는 false 를 반환한다.
        if let modifiers = self.modifiers,
           modifiers.count > 0 {
            return false
        }
        // key가 없는 경우 false 를 반환한다.
        guard let key = self.key else { return false }
        // 현재 키가 특수 키인 경우, true를 반환한다.
        return key.isSpecialKey
        
    }
    /// 대체 단축키 사용 여부
    var isAlternative: Bool = false
    /// 실제 대체 단축키 사용 가능 여부
    /// - `canAlternative` = true인 상황에서 `alternativeKey`가 설정된 경우, true를 반환한다.
    var shouldAlternative: Bool {
        return self.canAlternative && (self.alternativeKey != nil)
    }
    /// 대체 전환 방향
    /// - 전환 반향이 `Commander.Axis` 값으로 반환되며, 대체 전환 방향을 적용할 수 경우에는 널값이 반환된다.
    var alternativeAxis: EdgeCommander.Axis? {
        return self.alternativeKey?.axis
    }
    
    /// 대체 단축키 메뉴명
    var alternativeTitle: String?
    /// 대체 키
    var alternativeKey: String? {
        didSet {
            // 기존 값과 동일한지 확인
            guard oldValue != self.alternativeKey else { return }
            updateAlternativeShortcut()
        }
    }
    /// 대체 보조 키
    var alternativeModifiers: Set<Modifier>? {
        didSet {
            // 기존 값과 동일한지 확인
            guard oldValue != self.alternativeModifiers else { return }
            updateAlternativeShortcut()
        }
    }
    /// 대체 키 / 대체 보조 키 변경 시 호출되는 private 메쏘드
    /// - 단축키 및 문자열 업데이트를 실행한다
    private func updateAlternativeShortcut() {
        // 기존 값에서 변경된 경우
        if self.isAlternative == true {
            // 현재 대체 단축키 사용 상태면 단축키 업데이트 실행
            self.updateShortcut()
        }
        else {
            // 아닌 경우, 문자열만 업데이트한다.
            self.updateShortcutReadables()
        }
    }
    
    /// 대체 편집 키 셋을 NSEvent ModifierFlags 로 반환
    var alternativeModifierFlags: NSEvent.ModifierFlags {
        return EdgeCommander.convert(modifiers: self.alternativeModifiers)
    }
    /// 대체 단축키 스트링
    /// - 출력용으로 편집 키 셋과 입력 키 값을 조합해 구성
    var alternativeShortcutReadable: String?

    // MARK: - Intialization
    
    /// 초기화
    /// - Parameters:
    ///   - title: 메뉴명.
    ///   - action: 액션 Selector 로 기본값은 널값이다.
    ///   - target: 액션 타겟으로 기본값은 널값이다.
    ///   - tag: 메뉴아이템의 태그 값. 기본값은 0이다.
    public init(_ title: String,
                action: Selector? = nil,
                target: AnyObject? = nil,
                tag: Int = 0) {
        self.title = title
        self.action = action
        self.target = target
        self.tag = tag
    }
    /// 초기화
    /// - Root EdgeCommander 초기화에 사용되며, 메인 메뉴를 지정해 초기화한다.
    /// - Parameters:
    ///   - mainMenu: `NSMenu` 를 지정한다.
    ///   - initializeHandler: 이 클로저에서 `NSMenuItem`으로 하위 Commander를 초기화한다. 널값 지정도 가능하며 기본값은 널값이다.
    public convenience init(mainMenu: NSMenu,
                            _ initializeHandler: ((_ menuItem: NSMenuItem) -> EdgeCommander?)? = nil) {
        self.init(EdgeCommander.Label.mainMenu.rawValue)
        self.isRoot = true
        self.menu = mainMenu
        // 하위 commander의 전환 키 사용이 가능하도록 세팅
        self.canSwap = true
        
        // 하위 아이템을 재귀적으로 추가한다.
        addChild(initializeHandler)
    }
    /// 초기화
    /// - 서브 메뉴 아이템을 지정할 때 사용되며, 서브 메뉴를 지정해 초기화한다.
    /// - Parameters:
    ///   - title: 메뉴명.
    ///   - subMenu: 서브 메뉴로 `NSMenu` 를 지정한다.
    public convenience init(_ title: String,
                            subMenu: NSMenu) {
        self.init(title)
        self.isRoot = false
        self.menu = subMenu
        // 하위 commander의 전환 키 사용이 가능하도록 세팅
        self.canSwap = true
    }
    /// 초기화
    /// - `NSMenuItem`으로 초기화하며 편집 키, 키, 좌우 전환 키, 대체 단축키 등의 패러미터를 추가할 수 있다.
    /// - Important: action Selector 가 없는 `NSMenuItem`을 지정하면 초기화되지 않고 널값이 반환된다.
    /// - Parameters:
    ///   - menuItem: `NSMenuItem`
    ///   - key: 키 값으로 기본값은 널값이다.
    ///   - modifierFlags: 보조 키를 `NSEvent.ModifierFlags` 로 지정할 수 있다. 기본값은 널값이다.
    ///   - canSwap: 방향 전환 가능 여부를 지정하며, 기본값은 false이다.
    ///   - swapAxis: 전환 방향(가로/세로)를 지정하며, 기본값은 none이다.
    ///   - swapTitle: 방향 전환 시 대체될 메뉴명을 지정하며, 기본값은 널값이다.
    ///   - swapKeyEquivalent: 방향 전환 시 기본 키를 대체하게 되는 키 값을 지정하며, 기본값은 널값이다.
    ///   - alternativeTitle: 대체 단축키 적용시 표시될 메뉴명을 지정하며, 기본값은 널값이다.
    ///   - alternativeKey: 대체 키 값을 지정하며, 기본값은 널값이다.
    ///   - alternativeModifierFlags: 대체 보조 키 조합을 `NSEvent.ModifierFlags` 로 지정할 수 있다. 기본값은 널값이다.
    public convenience init?(_ menuItem: NSMenuItem,
                             key: String? = nil,
                             modifierFlags: NSEvent.ModifierFlags? = nil,
                             canSwap: Bool = false,
                             swapAxis: EdgeCommander.Axis = .none,
                             swapTitle: String? = nil,
                             swapKeyEquivalent: String? = nil,
                             alternativeTitle: String? = nil,
                             alternativeKey: String? = nil,
                             alternativeModifierFlags: NSEvent.ModifierFlags? = nil) {
        // action이 없는 메뉴 아이템인 경우 NIL 반환
        guard let action = menuItem.action else {
            return nil
        }
        // 기본 초기화
        self.init(menuItem.title,
                  action: action,
                  tag: menuItem.tag)
        self.menuItem           = menuItem
        // key, modifiers는 초기화 패러미터를 사용한다
        self.key                = key
        self.canSwap            = canSwap
        self.swapAxis           = swapAxis
        self.swapTitle          = swapTitle
        self.swapKey            = swapKeyEquivalent
        
        self.alternativeTitle   = alternativeTitle
        self.alternativeKey     = alternativeKey
        
        // 기본 보조 키 셋업 실행
        if let modifierFlags {
            self.setupModifiers(modifierFlags)
        }
        // 대체 보조 키 셋업 실행
        if let alternativeModifierFlags {
            self.setupAlternativeModifiers(alternativeModifierFlags)
        }
        
        // 대문자 키인 경우, 단축키에 Shift 추가
        self.checkUpperCaseKey()
        
        // 단축키 표시 스트링 업데이트
        self.updateShortcutReadables()
    }
    /// 초기화
    /// - Codable 프로토콜에 대응하는 초기화 방식이다.
    /// - Important: Aciton/메뉴/서브메뉴 등은 별도의 방법을 이용해서 설정해야 한다.
    required public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.title = try values.decode(String.self, forKey: .title)
        self.isRoot = try values.decode(Bool.self, forKey: .isRoot)
        self.canSwap = try values.decode(Bool.self, forKey: .canSwap)
        self.swapAxis = try values.decode(EdgeCommander.Axis.self, forKey: .swapDirection)
        if let children = try? values.decode([EdgeCommander].self, forKey: .children) {
            self.children = children
        }
        if let actionDescription = try? values.decode(String.self, forKey: .action) {
            self.actionDescription = actionDescription
        }
        if let tag = try? values.decode(Int.self, forKey: .tag) {
            self.tag = tag
        }
        if let key = try? values.decode(String.self, forKey: .key) {
            self.key = key
        }
        if let modifiers = try? values.decode(Set<EdgeCommander.Modifier>.self, forKey: .modifiers) {
            self.modifiers = modifiers
        }
        if let swapTitle = try? values.decode(String.self, forKey: .swapTitle) {
            self.swapTitle = swapTitle
        }
        if let swapKey = try? values.decode(String.self, forKey: .swapKey) {
            self.swapKey = swapKey
        }
        if let alternativeTitle = try? values.decode(String.self, forKey: .alterTitle) {
            self.alternativeTitle = alternativeTitle
        }
        if let alternativeKey = try? values.decode(String.self, forKey: .alterKey) {
            self.alternativeKey = alternativeKey
        }
        if let alternativeModifiers = try? values.decode(Set<EdgeCommander.Modifier>.self, forKey: .alterModifiers) {
            self.alternativeModifiers = alternativeModifiers
        }
    }
    
    /// 보조 키 설정 private 메쏘드
    /// - Parameter modifierFlags: 보조 키를 격납한 `NSEvent.modifers`.
    private func setupModifiers(_ modifierFlags: NSEvent.ModifierFlags) {
        self.modifiers = modifierFlags.toModifiers()
    }
    /// 대체 보조 키 설정 private 메쏘드
    /// - Parameter modifierFlags: 대체 보조 키를 격납한 `NSEvent.modifers`.
    private func setupAlternativeModifiers(_ modifierFlags: NSEvent.ModifierFlags) {
        self.alternativeModifiers = modifierFlags.toModifiers()
    }
    
    /// 대문자 키 추가 private 메쏘드
    /// - 현재 키 값이 대문자인 경우, 보조 키에 shift 키를 추가한다.
    private func checkUpperCaseKey() {
        guard let key = self.key else { return }
        guard key.count > 0 else { return }
        let char = key[key.startIndex]
        if char.isUppercase == true {
            if self.modifiers == nil { self.modifiers = Set<EdgeCommander.Modifier>() }
            self.modifiers?.insert(.shift)
        }
    }
    
    /// 하위 `Commander`를 재귀적으로 추가하는 메쏘드
    /// - Root Commander 에서 초기화 시 호출, initializeHandler 클로저를 통해 하위 아이템을 재귀적으로 추가한다.
    /// - Parameter initializeHandler: 이 클로저에서 `NSMenuItem`으로 하위 Commander를 초기화한다. 널값 지정도 가능하다.
    /// - Returns: 하위 EdgeCommander 추가 성공 시 true를 반환, 실패 시에는 false를 반환한다.
    @discardableResult
    func addChild(_ initializeHandler: ((_ menuItem: NSMenuItem) -> EdgeCommander?)?) -> Bool {
        // 하위 EdgeCommander 배열
        var children = [EdgeCommander]()
        
        guard let menu = self.menu else {
            EdgeLogger.shared.uiLogger.debug("\(#file):\(#function) :: 하위 EdgeCommander를 추가할 수 없습니다. 메뉴가 없습니다.")
            return false
        }
        
        for menuItem in menu.items {
            //--------------------------------------------------------------//
            /// 하위 EdgeCommander를 추가하는 내부 메소드
            func addChild() {
                guard let initializeHandler else {
                    // initializeHandler 가 없는 경우
                    // menuItem으로 초기화 시도
                    guard let commander = EdgeCommander(menuItem) else {
                        EdgeLogger.shared.uiLogger.debug("\(#file):\(#function) :: \(menuItem.title) 로 하위 EdgeCommander를 생성할 수 없습니다.")
                        // 다음 아이템으로 이동
                        return
                    }
                    // 하위 commander 추가
                    children.append(commander)
                    return
                }
                // initializeHandler 로 commander 생성
                guard let commander = initializeHandler(menuItem) else {
                    EdgeLogger.shared.uiLogger.debug("\(#file):\(#function) :: initializeHandler로 하위 EdgeCommander를 생성할 수 없습니다.")
                    // 다음 아이템으로 이동
                    return
                }
                // 하위 commander 추가
                children.append(commander)
            }
            //--------------------------------------------------------------//

            // SubMenu 아이템인지 확인
            guard let subMenu = menuItem.submenu else {
                // 일반 아이템인 경우, 추가 실행
                addChild()
                continue
            }
            
            // SubMenu 아이템인 경우
            // 하위 아이템 생성
            let commander = EdgeCommander(menuItem.title, subMenu: subMenu)
            guard commander.addChild(initializeHandler) == true else {
                // 하위 아이템이 0인 경우, 추가 없이 건너뛴다
                continue
            }
            // 하위 commander 추가
            children.append(commander)
        }
        
        // 하위 commander 추가 여부 확인
        guard children.count > 0 else {
            // 하위 commander가 없는 경우 false 반환
            return false
        }
        // 하위 commander 가 추가된 경우
        // children 프로퍼티에 추가
        if self.children == nil {
            self.children = [EdgeCommander]()
        }
        self.children?.append(contentsOf: children)
        // true 반환
        return true
    }
    
    // MARK: - Methods
    
    /// 메뉴아이템 단축키 및 단축키 스트링 업데이트
    /// - Root EdgeCommander에서 최초로 사용되며, 모든 하위 EdgeCommander를 업데이트한다.
    func updateShortcuts() {
        guard let children = self.children else {
            return self.updateShortcut()
        }
        for commander in children {
            commander.updateShortcuts()
        }
    }
    
    /// 메뉴아이템 단축키 및 단축키 스트링 업데이트
    func updateShortcut() {
        // 메뉴아이템이 없는 경우 중지
        guard let menuItem = self.menuItem else { return }
        
        //-------------------------------------------------------------------------//
        /// 타이틀과 액션을 지정하는 내부 메쏘드
        func setupDefault(isSwap: Bool) {
            switch isSwap {
                // 일반 단축키
            case false:
                // title 지정
                if menuItem.title != self.title {
                    // 번역된 스트링으로 지정한다.
                    let localizedTitle = LocalizedStringResource(stringLiteral: self.title)
                    menuItem.title = String(localized: localizedTitle)
                }
                
                // 전환시
            case true:
                // swap title 지정
                if let swapTitle = self.swapTitle,
                   menuItem.title != swapTitle {
                    // 번역된 스트링으로 지정
                    let localizedTitle = LocalizedStringResource(stringLiteral: swapTitle)
                    menuItem.title = String(localized: localizedTitle)
                }
            }
        }
        //-------------------------------------------------------------------------//
        //-------------------------------------------------------------------------//
        /// 대체 타이틀을 지정하는 내부 메쏘드
        func setupAlternative() {
            // alternative title 지정
            if let alternativeTitle = self.alternativeTitle,
               menuItem.title != alternativeTitle {
                // 번역된 스트링으로 지정
                let localizedTitle = LocalizedStringResource(stringLiteral: alternativeTitle)
                menuItem.title = String(localized: localizedTitle)
            }
        }
        //-------------------------------------------------------------------------//
        
        // 업데이트될 키 값
        var key: String?
        // 업데이트될 편집 키 값
        var modifierFlags: NSEvent.ModifierFlags = self.modifierFlags
        
        // 전환 여부 확인
        // 전환 X
        if self.isSwap == false {
            // 일반 단축키
            if self.isAlternative == false {
                key = self.key
                // 타이틀과 액션을 지정
                setupDefault(isSwap: false)
            }
            // 대체 단축키 사용시
            else {
                // alternative Key가 있는 경우, key / modifierFlags 를 대체 키 / 대체 보조키로 지정
                if let alternativeKey = self.alternativeKey {
                    key = alternativeKey
                    modifierFlags = self.alternativeModifierFlags
                }
                else {
                    key = self.key
                }
                // 대체 타이틀과 액션을 지정
                setupAlternative()
            }
        }
        // 상하/좌우 전환시
        else {
            // 전환 단축키
            if self.isAlternative == false {
                // swapKey가 없는 경우, key를 지정
                key = self.swapKey != nil ? self.swapKey : self.key
                // 일반 타이틀과 액션을 지정
                setupDefault(isSwap: true)
            }
            // 대체 + 전환 단축키
            else {
                // swapKey, alternative key, 일반 key를 차례로 지정하도록 한다
                if let swapKey = self.swapKey {
                    key = swapKey
                }
                else if let alternativeKey = self.alternativeKey {
                    key = alternativeKey
                }
                else {
                    key = self.key
                }
                
                // modifierFlags 를 대체 편집키로 지정
                modifierFlags = self.alternativeModifierFlags
                
                // 대체 타이틀과 액션을 지정
                setupAlternative()
            }
        }
        
        if key != nil {

            /// #키 변경 발생시 업데이트
            /// - 현재는 Readable 값도 달라진 경우에만 업데이트 처리한다.
            /// 문제가 생기는 경우에는, `menuItem.keyEquivalent.readable != key?.readable` 부분을 주석 처리하도록 한다.

            if menuItem.keyEquivalent != key,
               menuItem.keyEquivalent.readable != key?.readable {
                EdgeLogger.shared.uiLogger.debug("\(#file):\(#function) :: \(menuItem.title) >> Swap 여부 = \(self.isSwap), \(menuItem.keyEquivalent.readable) => \(key?.readable ?? "none")")
                // 키값 업데이트
                menuItem.keyEquivalent = key!
            }
        }
        else {
            EdgeLogger.shared.uiLogger.debug("\(#file):\(#function) :: \(menuItem.title) >> 키 값이 없습니다.")
            // 키가 NIL 인 경우 공백 삽입
            menuItem.keyEquivalent = ""
        }
        
        // 편집 키 변경 발생시 업데이트
        if menuItem.keyEquivalentModifierMask != modifierFlags {
            EdgeLogger.shared.uiLogger.debug("\(#file):\(#function) :: \(menuItem.title) >> \(menuItem.keyEquivalentModifierMask.rawValue) => \(modifierFlags.rawValue) 로 보조 키 변경.")
            menuItem.keyEquivalentModifierMask = modifierFlags
        }
        
        // 단축키 스트링 업데이트
        self.updateShortcutReadables()
    }
    
    // MARK: Swap Shortcuts
    
    /// # RootCommander 전용 메쏘드
    
    /// 전체 좌우 전환
    /// - 모든 하위 EdgeCommander 방향을 전환한다. 단, 방향 전환 단축키가 지정된 EdgeCommander만 가능하다.
    /// - Parameter isSwap: 전환 여부를 지정한다.
    /// - Returns: 전환 단축키 적용 여부를 반환한다. 전환 단축키가 없거나 적용에 실패하면 false를 반환한다.
    @discardableResult
    func swapHorizontalAll(_ isSwap: Bool) -> Bool {
        // Root EdgeCommander 여부 확인
        guard isRoot else { return false }
        return self.setSwap(isSwap, swapAxis: .horizontal, includeChildren: true)
    }
    /// 전체 상하 전환
    /// - 모든 하위 EdgeCommander 방향을 전환한다. 단, 방향 전환 단축키가 지정된 EdgeCommander만 가능하다.
    /// - Parameter isSwap: 전환 여부를 지정한다.
    /// - Returns: 전환 단축키 적용 여부를 반환한다. 전환 단축키가 없거나 적용에 실패하면 false를 반환한다.
    @discardableResult
    func swapVerticalAll(_ isSwap: Bool) -> Bool {
        // Root EdgeCommander 여부 확인
        guard isRoot else { return false }
        return self.setSwap(isSwap, swapAxis: .vertical, includeChildren: true)
    }
    /// 하위 메뉴아이템 셋의 좌우 전환
    /// - Parameters:
    ///   - menuItems: 전환할 메뉴아이템 셋을 지정한다.
    ///   - isSwap: 전환 여부를 지정한다.
    /// - Returns: 전환 단축키 적용 여부를 반환한다. 1개라도 전환된 경우엔 true를, 모두 적용에 실패하면 false를 반환한다.
    @discardableResult
    func swapHorizontal(at menuItems: Set<NSMenuItem>, _ isSwap: Bool) -> Bool {
        // Root EdgeCommander 여부 확인
        guard isRoot else { return false }
        var success = false
        for menuItem in menuItems {
            guard let commander = self.find(menuItem: menuItem) else {
                continue
            }
            if commander.setSwap(isSwap, swapAxis: .horizontal, includeChildren: false) == true {
                success = true
            }
        }
        // 1개라도 전환된 아이템이 있으면 성공 값을 반환한다
        return success
    }
    /// 하위 메뉴아이템 셋의 상하 전환
    /// - Parameters:
    ///   - menuItems: 전환할 메뉴아이템 셋을 지정한다.
    ///   - isSwap: 전환 여부를 지정한다.
    /// - Returns: 전환 단축키 적용 여부를 반환한다. 1개라도 전환된 경우엔 true를, 모두 적용에 실패하면 false를 반환한다.
    @discardableResult
    func swapVertical(at menuItems: Set<NSMenuItem>, _ isSwap: Bool) -> Bool {
        guard isRoot else { return false }
        var success = false
        for menuItem in menuItems {
            guard let commander = self.find(menuItem: menuItem) else { continue }
            if commander.setSwap(isSwap, swapAxis: .vertical, includeChildren: false) == true {
                success = true
            }
        }
        // 1개라도 전환된 아이템이 있으면 성공 값을 반환한다
        return success
    }
    /// 지정된 액션을 포함하는 하위 메뉴아이템 셋의 좌우 전환
    /// - Parameters:
    ///   - actions: 전환할 액션 셋을 지정한다.
    ///   - isSwap: 전환 여부를 지정한다.
    /// - Returns: 전환 단축키 적용 여부를 반환한다. 1개라도 전환된 경우엔 true를, 모두 적용에 실패하면 false를 반환한다.
    @discardableResult
    func swapHorizontal(of actions: Set<Selector>, _ isSwap: Bool) -> Bool {
        // Root EdgeCommander 여부 확인
        guard isRoot else { return false }
        var success = false
        for action in actions {
            guard let commanders = self.find(action: action) else { continue }
            for commander in commanders {
                if commander.setSwap(isSwap, swapAxis: .horizontal, includeChildren: false) == true {
                    success = true
                }
            }
        }
        // 1개라도 전환된 아이템이 있으면 성공 값을 반환한다
        return success
    }
    /// 지정된 액션을 포함하는 하위 메뉴아이템 셋의 상하 전환
    /// - Parameters:
    ///   - actions: 전환할 액션 셋을 지정한다.
    ///   - isSwap: 전환 여부를 지정한다.
    /// - Returns: 전환 단축키 적용 여부를 반환한다. 1개라도 전환된 경우엔 true를, 모두 적용에 실패하면 false를 반환한다.
    @discardableResult
    func swapVertical(of actions: Set<Selector>, _ isSwap: Bool) -> Bool {
        // Root EdgeCommander 여부 확인
        guard isRoot else { return false }
        var success = false
        for action in actions {
            guard let commanders = self.find(action: action) else { continue }
            for commander in commanders {
                if commander.setSwap(isSwap, swapAxis: .vertical, includeChildren: false) == true {
                    success = true
                }
            }
        }
        // 1개라도 전환된 아이템이 있으면 성공 값을 반환한다
        return success
    }
    /// 상하/좌우 전환 적용 private 메쏘드
    /// - Parameters:
    ///   - isSwap: 전환 여부를 지정한다.
   ///    - swapAxis: 전환 방향을 지정한다.
    ///   - includeChildren: 하위 아이템까지 적용할지 여부를 지정한다.
    /// - Returns: 전환 단축키 적용 여부를 반환한다. 1개라도 전환된 경우엔 true를, 모두 적용에 실패하면 false를 반환한다.
    @discardableResult
    private func setSwap(_ isSwap: Bool, swapAxis: EdgeCommander.Axis, includeChildren: Bool) -> Bool {
        // canSwap이 false인 경우 중지
        guard self.canSwap == true else {
            return false
        }
        
        //---------------------------------------------------------------------//
        /// 방향 전환용 내부 메소드
        func setSwap(_ isSwap: Bool) -> Bool {
            // 현재 isSwap 상태와 다른 경우에만 진행
            guard self.isSwap != isSwap else {
                return false
            }
            // isSwap 값 대입
            self.isSwap = isSwap
            // 단축키 업데이트
            self.updateShortcut()
            return true
        }
        //---------------------------------------------------------------------//
        
        var success = false
        // 전환 방향이 동일한 경우
        if self.swapAxis == swapAxis {
            success = setSwap(isSwap)
        }
        // 방향이 다른 경우
        // 전환 상태를 false로 초기화
        else {
            // 현재 isSwap 상태가 true인 경우, false 로 전환
            success = setSwap(false)
        }
        
        // children 포함 전환시
        if includeChildren == true {
            // 하위 EdgeCommander 존재 여부 확인
            guard let children = self.children else { return success }
            for commander in children {
                if commander.setSwap(isSwap, swapAxis: swapAxis, includeChildren: true) == true {
                    // 하위 commander에서 변경 발생시 성공으로 간주
                    success = true
                }
            }
        }
        // 1개라도 전환된 아이템이 있으면 성공 값을 반환한다
        return success
    }
    
    // MARK: Set Alternative Shortcuts
    
    /// # RootCommander 전용 메쏘드

    /// 전체 대체 단축키 전환
    /// - 모든 하위 EdgeCommander를 대체 단축키로 전환한다. 단, 대체 키가 지정된 EdgeCommander만 가능하다.
    /// - Parameter isAlternative: 대체 단축키 사용 여부를 지정한다.
    /// - Returns: 대체 단축키 적용 여부를 반환한다. 1개라도 전환된 경우엔 true를, 모두 적용에 실패하면 false를 반환한다.
    @discardableResult
    func setAlternativeAll(_ isAlternative: Bool) -> Bool {
        // Root EdgeCommander 여부 확인
        guard isRoot else { return false }
        return self.setAlternative(isAlternative, alterAxis: nil, includeChildren: true)
    }
    /// 수평 대체 단축키 전환
    /// - 모든 하위 EdgeCommander를 수평 대체 단축키로 전환한다. 단, 대체 키가 지정된 EdgeCommander만 가능하다.
    /// - Parameter isAlternative: 대체 단축키 사용 여부를 지정한다.
    /// - Returns: 대체 단축키 적용 여부를 반환한다. 1개라도 전환된 경우엔 true를, 모두 적용에 실패하면 false를 반환한다.
    @discardableResult
    func setAlternativeHorizontal(_ isAlternative: Bool) -> Bool {
        // Root EdgeCommander 여부 확인
        guard isRoot else { return false }
        return self.setAlternative(isAlternative, alterAxis: .horizontal, includeChildren: true)
    }
    /// 수직 대체 단축키 전환
    /// - 모든 하위 EdgeCommander를 대체 단축키로 전환한다. 단, 대체 키가 지정된 EdgeCommander만 가능하다.
    /// - Parameter isAlternative: 대체 단축키 사용 여부를 지정한다.
    /// - Returns: 대체 단축키 적용 여부를 반환한다. 1개라도 전환된 경우엔 true를, 모두 적용에 실패하면 false를 반환한다.
    @discardableResult
    func setAlternativeVertical(_ isAlternative: Bool) -> Bool {
        return self.setAlternative(isAlternative, alterAxis: .vertical, includeChildren: true)
    }
    /// 하위 메뉴아이템 셋의 수평 대체 단축키 전환
    /// - Parameters:
    ///   - menuItems: 전환할 메뉴아이템 셋을 지정한다.
    ///   - isAlternative: 대체 단축키 사용 여부를 지정한다.
    /// - Returns: 대체 단축키 적용 여부를 반환한다. 1개라도 전환된 경우엔 true를, 모두 적용에 실패하면 false를 반환한다.
    @discardableResult
    func setAlternativeHorizontal(at menuItems: Set<NSMenuItem>, _ isAlternative: Bool) -> Bool {
        // Root EdgeCommander 여부 확인
        guard isRoot else { return false }
        return self.setAlternative(at: menuItems, isAlternative, alterAxis: .horizontal)
    }
    /// 하위 메뉴아이템 셋의 수직 대체 단축키 전환
    /// - Parameters:
    ///   - menuItems: 전환할 메뉴아이템 셋을 지정한다.
    ///   - isAlternative: 대체 단축키 사용 여부를 지정한다.
    /// - Returns: 대체 단축키 적용 여부를 반환한다. 1개라도 전환된 경우엔 true를, 모두 적용에 실패하면 false를 반환한다.
    @discardableResult
    func setAlternativeVertical(at menuItems: Set<NSMenuItem>, _ isAlternative: Bool) -> Bool {
        // Root EdgeCommander 여부 확인
        guard isRoot else { return false }
        return self.setAlternative(at: menuItems, isAlternative, alterAxis: .vertical)
    }
    /// 하위 메뉴아이템 셋의 대체 단축키 전환 private 메쏘드
    /// - Parameters:
    ///   - menuItems: 전환할 메뉴아이템 셋을 지정한다.
    ///   - isAlternative: 대체 단축키 사용 여부를 지정한다.
    ///   - alterAixs: 전환할 대체 단축키의 방향을 지정한다. 널 값을 지정하면 수평/수직 방향을 가리지 않고 전체를 대체 키로 전환한다.
    /// - Returns: 대체 단축키 적용 여부를 반환한다. 1개라도 전환된 경우엔 true를, 모두 적용에 실패하면 false를 반환한다.
    @discardableResult
    private func setAlternative(at menuItems: Set<NSMenuItem>,
                                _ isAlternative: Bool,
                                alterAxis: EdgeCommander.Axis? = nil) -> Bool {
        // Root EdgeCommander 여부 확인
        guard isRoot else { return false }
        var success = false
        for menuItem in menuItems {
            guard let commander = self.find(menuItem: menuItem) else { return false }
            if commander.setAlternative(isAlternative, alterAxis: alterAxis, includeChildren: false) == true {
                success = true
            }
        }
        // 1개라도 전환된 아이템이 있으면 성공 값을 반환한다
        return success
    }
    /// 대체 단축키 전환 private 메쏘드
    /// - Parameters:
    ///   - alterAixs: 전환할 대체 단축키의 방향을 지정한다. 널 값을 지정하면 수평/수직 방향을 가리지 않고 전체를 대체 키로 전환한다.
    ///   - isAlternative: 대체 단축키 사용 여부를 지정한다.
    ///   - includeChildren: 하위 EdgeCommander도 대체 단축키로 전환할지 여부를 지정한다.
    /// - Returns: 대체 단축키 적용 여부를 반환한다. 1개라도 전환된 경우엔 true를, 모두 적용에 실패하면 false를 반환한다.
    @discardableResult
    private func setAlternative(_ isAlternative: Bool, alterAxis: EdgeCommander.Axis?, includeChildren: Bool) -> Bool {
        
        // canAlternative가 false인 경우 중지
        guard self.canAlternative == true else {
            return false
        }
        
        //-------------------------------------------------------------------//
        /// 대체 단축키 전환 처리용 내부 메쏘드
        func setAlternative(_ isAlternative: Bool) -> Bool {
            // 현재 alternative 상태와 다른 경우에만 진행
            guard self.isAlternative != isAlternative else { return false }
            self.isAlternative = isAlternative
            // 단축키 업데이트
            self.updateShortcut()
            return true
        }
        //-------------------------------------------------------------------//
        
        var success = false
        // 대체 단축키 전환 방향 확인
        if let alterAxis = alterAxis {
            // self의 전환 방향이 동일하거나, none인 경우 전환 처리
            if self.alternativeAxis == alterAxis || self.alternativeAxis == EdgeCommander.Axis.none {
                success = setAlternative(isAlternative)
            }
            // 전환 방향이 다른 경우
            else {
                // 강제로 false로 전환
                success = setAlternative(false)
            }
        }
        // 전환 방향이 nil인 경우 그대로 전환 처리
        else {
            success = setAlternative(isAlternative)
        }
        
        // children 포함 전환시
        if includeChildren == true {
            // 하위 EdgeCommander 존재 여부 확인
            guard let children = self.children else { return success }
            // 하위 EdgeCommander도 동일하게 전환
            for commander in children {
                if commander.setAlternative(isAlternative, alterAxis: alterAxis, includeChildren: true) == true {
                    // 하위 commander에서 변경 발생시 성공으로 간주
                    success = true
                }
            }
        }
        // 1개라도 전환된 아이템이 있으면 성공 값을 반환한다
        return success
    }
    
    // MARK: Update MenuItem's String
    
    /// 단축키 문자열을 갱신한다
    /// - 방향 전환, 대체 단축키 적용 시 또는 해제 시마다 이 메쏘드를 호출해 메뉴아이템에 표시될 단축키 문자열을 갱시한다.
    private func updateShortcutReadables() {
        
        // 기존 스트링 제거
        self.shortcutReadable = nil
        // 새로운 숏컷 키 스트링 대입
        self.shortcutReadable = EdgeCommander.shortcutReadable(modifiers: self.modifiers, key: self.key)
        // 기존 대체 단축키 스트링 제거
        self.alternativeShortcutReadable = nil
        // 새로운 대체 숏컷 키 스트링 대입
        self.alternativeShortcutReadable = EdgeCommander.shortcutReadable(modifiers: self.alternativeModifiers, key: self.alternativeKey)
    }
    
    // MARK: Remove EdgeCommander

    /// 특정 EdgeCommander를 children에서 재귀적으로 찾아서 제거한다
    /// - Parameter commander: 제거하려는 하위 EdgeCommander로, 내부 children에 없으면 하위 EdgeCommander의 children을 계속 탐색한다.
    /// - Returns: 제거 성공 여부를 반환한다.
    @discardableResult
    func remove(_ commander: EdgeCommander) -> Bool {
        guard let children = self.children else { return false }
        guard let index = children.firstIndex(of: commander),
              0 ..< children.count ~= index else {
            
            for childCommander in children {
                guard childCommander.remove(commander) == true else { continue }
                return true
            }
            return false
        }
        // children에서 제거
        self.children?.remove(at: index)
        return true
    }
}

// MARK: - Copying Extensions for EdgeCommander
extension EdgeCommander {
    
    /// 복사 메쏘드
    public func copy(with zone: NSZone? = nil) -> Any {
        
        var commander: EdgeCommander
        // 루트 아이템인 경우
        if self.isRoot == true {
            guard let menu else {
                fatalError("\(#file):\(#function) :: 루트 아이템의 메뉴가 널값입니다.")
            }
            commander = EdgeCommander(mainMenu: menu)
        }
        else {
            // 서브메뉴 아이템인 경우
            if self.isParent == true {
                guard let menu else {
                    fatalError("\(#file):\(#function) :: 서브메뉴 아이템의 메뉴가 널값입니다.")
                }
                commander = EdgeCommander.init(self.title, subMenu: menu)
            }
            // 일반 아이템인 경우
            else {
                commander = EdgeCommander.init(self.menuItem!,
                                           key: self.key ?? self.menuItem!.keyEquivalent,
                                           modifierFlags: self.modifierFlags,
                                           canSwap: self.canSwap,
                                           swapAxis: self.swapAxis,
                                           swapTitle: self.swapTitle,
                                           swapKeyEquivalent: self.swapKey,
                                           alternativeTitle: self.alternativeTitle,
                                           alternativeKey: self.alternativeKey,
                                           alternativeModifierFlags: self.alternativeModifierFlags)!
            }
        }
        
        if let children {
            commander.children = [EdgeCommander]()
            for childCommander in children {
                // child commander를 복사해서 children에 추가
                commander.children?.append(childCommander.copy() as! EdgeCommander)
            }
        }
        
        return commander
    }
}

// MARK: - Coding Extension for EdgeCommander
extension EdgeCommander {
    
    /// 인코딩 메쏘드
    /// - Important: Action, Menu, MenuItem 등은 제외한다
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.isRoot, forKey: .isRoot)
        try container.encode(self.title, forKey: .title)
        try container.encode(self.canSwap, forKey: .canSwap)
        try container.encode(self.swapAxis, forKey: .swapDirection)
        if let children = self.children {
            try container.encode(children, forKey: .children)
        }
        if let key = self.key {
            try container.encode(key, forKey: .key)
        }
        if let modifiers = self.modifiers {
            try container.encode(modifiers, forKey: .modifiers)
        }
        if let swapKey = self.swapKey {
            try container.encode(swapKey, forKey: .swapKey)
        }
        if let swapTitle = self.swapTitle {
            try container.encode(swapTitle, forKey: .swapTitle)
        }
        if let actionDescription = self.actionDescription {
            // action 은 selector 대신 description을 인코딩한다
            try container.encode(actionDescription, forKey: .action)
        }
        
        try container.encode(self.tag, forKey: .tag)
        
        if let alternativeKey = self.alternativeKey {
            try container.encode(alternativeKey, forKey: .alterKey)
        }
        if let alternativeModifers = self.alternativeModifiers {
            try container.encode(alternativeModifers, forKey: .alterModifiers)
        }
        if let alternativeTitle = self.alternativeTitle {
            try container.encode(alternativeTitle, forKey: .alterTitle)
        }
    }
    
    // MARK: Convert ModiferFlags
    /// modifiers 셋을 NSEvent.ModifierFlags로 변환하는 정적 메쏘드
    /// - Parameter modifiers: 보조 키 셋.
    /// - Returns: `NSEvent.ModifierFlags`로 변환해 반환한다.
    static internal func convert(modifiers: Set<Modifier>?) -> NSEvent.ModifierFlags {
        var modifierFlags = NSEvent.ModifierFlags.init()
        guard let modifiers = modifiers,
              modifiers.count > 0 else { return modifierFlags }
        // Command 포함시
        if modifiers.contains(.command) {
            modifierFlags.insert(.command)
        }
        // Option 포함시
        if modifiers.contains(.option) {
            modifierFlags.insert(.option)
        }
        // Control 포함시
        if modifiers.contains(.control) {
            modifierFlags.insert(.control)
        }
        // Shift 포함시
        if modifiers.contains(.shift) {
            modifierFlags.insert(.shift)
        }
        // Function 포함시
        if modifiers.contains(.function) {
            modifierFlags.insert(.function)
        }
        // CapsLock 포함시
        if modifiers.contains(.capsLock) {
            modifierFlags.insert(.capsLock)
        }
        return modifierFlags
    }
}

// MARK: - Collection Extension for EdgeCommander

/// 하위 EdgeCommander 반환을 위한 Collection 프로토콜 대응
extension EdgeCommander: @MainActor Collection {

    public func index(after i: Int) -> Int {
        return i+1
    }
    public var startIndex: Int {
        get { return 0 }
    }
    public var endIndex: Int {
        get {
            return self.children?.count ?? 0
        }
    }
    /// 특정 인덱스의 EdgeCommander 반환
    public subscript(index: Int)-> EdgeCommander? {
        guard 0 ..< endIndex ~= index else {
            return nil
        }
        return self.children?[index]
    }
    
    // MARK: Find EdgeCommander
    
    /// # RootCommander 전용 메쏘드
    
    /// 특정 `Selector`를 가진 `Commander` 셋을 반환한다
    /// - Important: tag가 다른 `Commander`들이 있는 경우, 모두 찾아서 셋으로 묶어 반환한다.
    /// - Parameter action: 찾으려는 `Selector`를 지정한다.
    /// - Returns: 검색한 `Commander`를 셋으로 반환한다.
    func find(action: Selector) -> Set<EdgeCommander>? {
        var commanders = Set<EdgeCommander>()
        
        // children 유무 확인
        guard let children = self.children else {
            // 없는 경우, 자기 자신과 비교
            guard self.action == action else {
                return nil
            }
            // commanders에 추가해서 반환
            commanders.insert(self)
            return commanders
        }
        // 내부 children 순환
        for commander in children {
            guard let subCommanders = commander.find(action: action) else {
                continue
            }
            commanders.formUnion(subCommanders)
        }
        
        guard commanders.count > 0 else {
            return nil
        }
        return commanders
    }
    
    /// 특정 action description 및 tag와 일치하는 EdgeCommander 반환 메쏘드
    /// - Parameters:
    ///   - actionDescription: 검색할 action description 문자열.
    ///   - tag: 검색할 태그 값. 널값 지정 시 태그 검색은 생략한다.
    /// - Returns: 발견 시 해당 `Commander`를 반환하고, 미발견 시 널값을 반환한다.
    func find(actionDescription: String, tag: Int?) -> EdgeCommander? {
        // children 유무 확인
        guard let children else {
            // 없는 경우, 자기 자신과 비교해서 맞는 경우 반환
            if self.actionDescription == actionDescription,
               self.tag == tag { return self }
            else { return nil }
        }
        // 내부 children 순환
        for commander in children {
            guard let commander = commander.find(actionDescription: actionDescription, tag: tag) else {
                continue
            }
            return commander
        }
        // 미발견시 nil 반환
        return nil
    }

    /// 특정 `NSMenuItem`을 격납한 `Commander` 반환
    /// - Parameter menuItem: 찾으려는 메뉴아이템.
    /// - Returns: 해당 메뉴아이템을 격납한 EdgeCommander을 반환한다. 없는 경우 널값을 반환한다.
    func find(menuItem: NSMenuItem) -> EdgeCommander? {
        // children 유무 확인
        guard let children else {
            // 없는 경우, 자기 자신의 메뉴아이템과 비교해서 맞는 경우 반환
            if self.menuItem == menuItem {
                return self
            }
            else {
                return nil
            }
        }
        // 내부 children 순환
        for commander in children {
            guard let commander = commander.find(menuItem: menuItem) else {
                continue
            }
            return commander
        }
        // 미발견시 nil 반환
        return nil
    }
    
    /// 주어진 키 값 및 보조 키와 일치하는 EdgeCommander 반환
    /// - `NSEvent.ModifierFlags.intersection(.deviceIndependentFlagsMask) == 비교할 NSEvent.ModifierFlags` 라는 식으로 실행한다.
    /// - Important:
    ///   - [참고 링크](https://stackoverflow.com/questions/47255354/swift-4-bitwise-and-for-nsevent-modifierflags) 방식으로도 View에서 입력받은 ModifierFlags를 정확하게 파악할 수 없는 경우가 있다.
    ///   - 따라서 `NSEvent.ModifierFlags`를 `Set<Modifier>`로 변경해서 비교할 필요가 있다.
    /// - Parameters:
    ///   - key: 검색할 키 값을 지정한다.
    ///   - modifierFlags: `NSEvent.ModifierFlags`로 정의된 보조 키 값을 지정한다.
    /// - Returns: 발견 시 해당 `Commander`를 반환하고, 미발견 시 널값을 반환한다.
    func find(key: String, modifierFlags: NSEvent.ModifierFlags?) -> EdgeCommander? {
        return self.find(key: key, modifiers: modifierFlags?.toModifiers())
    }
     /// 주어진 키 값 및 보조 키와 일치하는 EdgeCommander 반환 private 메쏘드
    /// - Parameters:
    ///   - key: 검색할 키 값을 지정한다.
    ///   - modifier: `EdgeCommander.Modifier` 셋으로 정의된 보조 키 값을 지정한다.
    /// - Returns: 발견 시 해당 `EdgeCommander`를 반환하고, 미발견 시 널값을 반환한다.
    private func find(key: String, modifiers: Set<EdgeCommander.Modifier>?) -> EdgeCommander? {
        // children 유무 확인
        guard let children = self.children else {
            // 없는 경우, 자기 자신과 비교해서 맞는 경우 반환
            // readable 값으로 비교해야 정확하게 비교된다
            guard self.menuItem?.keyEquivalent.readable == key.readable else { return nil }
            
            // 자기 자신의 현재 modifiers를 가져온다
            guard let currentModifiers = self.currentModifiers else {
                if modifiers == nil {
                    // 비교할 modifiers 도 nil인 경우, self 반환
                    return self
                }
                // 아닌 경우 nil 반환
                return nil
            }
            // 자기 자신의 modifiers와 검색 대상 modifiers를 비교
            if currentModifiers == modifiers {
                // 동일한 경우, 자기 자신을 반환
                return self
            }
            return nil
        }
        // 내부 children 순환
        for commander in children {
            guard let commander = commander.find(key: key, modifiers: modifiers) else {
                continue
            }
            return commander
        }
        // 미발견시 nil 반환
        return nil
    }
    
    // MARK: Find Key Combination
    
    /// # RootCommander 전용 메쏘드
    
    /// 특정 단축키 조합과 일치하는 하위 EdgeCommander 반환
    /// - Important:
    ///   - findCommander가 다른 EdgeCommander 단축키와와 충돌하는지 여부를 탐색하는 것이 목적이다.
    ///   - 즉, 단축키 조합을 변경하려 할 때, 변경하려는 조합과 일치하는 EdgeCommander가 있는지 여부를 확인하는 용도로 사용한다.
    ///   - 이 메쏘드는 Root EdgeCommander 에서 실행해야 한다.
    /// - Parameters:
    ///   - willChangeKey: 키 값을 지정한다.
    ///   - willChangeModifiers: 보조 키를 `EdgeCommander.Modifier`의 셋으로 지정한다. 널값 지정이 가능하다.
    ///   - willChangeCommander: 비교하려는 `EdgeCommander`를 지정한다.
    ///   - category: 비교하려는 카테고리(일반 키 / 전환 키 / 대체 키).
    /// - Returns: `EdgeCommander` 및 검색 결과 종류(일반 키 / 대체 키 구분)를 `FoundCommanderResult`로 반환한다. 없는 경우 널값을 반환한다.
    func find(key willChangeKey: String,
              modifiers willChangeModifiers: Set<EdgeCommander.Modifier>?,
              of willChangeCommander: EdgeCommander,
              _ category: EdgeCommander.Category) -> FoundCommander? {
        guard isRoot else {
            EdgeLogger.shared.uiLogger.debug("\(#file):\(#function) :: Root EdgeCommander가 아닙니다.")
            return nil
        }
        return _find(key: willChangeKey, modifiers: willChangeModifiers, of: willChangeCommander, category)
    }
    /// 특정 단축키 조합과 일치하는 하위 EdgeCommander 반환 실제 메쏘드
    /// - Important:
    ///   - 단축키 조합을 변경하려 할 때, 변경하려는 조합과 일치하는 EdgeCommander가 있는지 여부를 확인하는 용도로 사용한다.
    ///   - 이 메쏘드는 하위 EdgeCommander를 재귀적으로 탐색하여 결과를 반환하는 실제 메쏘드다.
    ///   - findCommander가 다른 EdgeCommander 단축키와와 충돌하는지 여부를 탐색하는 것이 목적이다.
    /// - Parameters:
    ///   - willChangeKey: 키 값을 지정한다.
    ///   - willChangeModifiers: 보조 키를 `Commander.Modifier`의 셋으로 지정한다. 널값 지정이 가능하다.
    ///   - shouldSwap: 방향 전환 가능 여부.
    ///   - shouldAlternative: 대체 단축키 사용 가능 여부.
    ///   - category: 비교하려는 카테고리(일반 키 / 전환 키 / 대체 단축키).
    /// - Returns: 검색해낸 EdgeCommander와 종류(일반 키 / 대체 단축키 구분)를 `FoundCommanderResult`로 즉시 반환한다. 찾지 못한 경우, 널값을 반환한다.
    func _find(key willChangeKey: String,
               modifiers willChangeModifiers: Set<EdgeCommander.Modifier>?,
               of willChangeCommander: EdgeCommander,
               _ category: EdgeCommander.Category) -> FoundCommander? {

        // commander가 자기 자신인 경우 nil 반환
        guard self != willChangeCommander else {
            return nil
        }
        
        // children 유무 확인
        guard let children else {
            // children이 없는 경우, 검색 실행
            
            // 실제 전환/대체 단축키 사용 가능 여부
            let findShouldSwap = willChangeCommander.shouldSwap
            let findShouldAlternative = willChangeCommander.shouldAlternative
            
            switch category {
                // 일반 단축키 검색
            case .normal:
                // 일반 키/일반 편집 키와 비교해서 동일한지 확인
                if willChangeKey == self.key && willChangeModifiers == self.modifiers {
                    // 일반 키 카테고리로 반환
                    return (commander: self, category: .normal)
                }
                
                // 검색하려는 findCommander는 swap이 불가능하고
                // 현재 self(commander)가 실제 swap 가능한 경우
                if findShouldSwap == false && self.shouldSwap == true {
                    // findKey를 self swapKey와 비교
                    if willChangeKey == self.swapKey && willChangeModifiers == self.modifiers {
                        // 전환 키 카테고리로 반환
                        return (commander: self, category: .swap)
                    }
                }
                // 검색하려는 findCommander는 alternative가 불가능하고
                // 현재 self(commander)가 alternative가 가능한 경우
                if findShouldAlternative == false && self.shouldAlternative == true {
                    if willChangeKey == self.alternativeKey && willChangeModifiers == self.alternativeModifiers {
                        // 대체 단축키 카테고리로 반환
                        return (commander: self, category: .alternative)
                    }
                }
                
                // 전환 키 검색
            case .swap:
                // 전환 키/일반 편집 키와 비교해서 동일한지 확인
                if willChangeKey == self.swapKey && willChangeModifiers == self.modifiers {
                    // 전환 키 카테고리로 반환
                    return (commander: self, category: .swap)
                }
                
                // 검색하려는 findCommander는 swap이 불가능하고
                // 현재 self(commander)가 실제 swap 가능한 경우
                if findShouldSwap == true && self.shouldSwap == false {
                    // findKey를 기본 단축키와 비교
                    if willChangeKey == self.key && willChangeModifiers == self.modifiers {
                        // 일반 키 카테고리로 반환
                        return (commander: self, category: .normal)
                    }
                }
                // 검색하려는 findCommander는 alternative가 불가능하고
                // 현재 self(commander)가 alternative가 가능한 경우
                if findShouldAlternative == false && self.shouldAlternative == true {
                    if willChangeKey == self.alternativeKey && willChangeModifiers == self.alternativeModifiers {
                        // 대체 단축키 카테고리로 반환
                        return (commander: self, category: .alternative)
                    }
                }
                
                // 대체 단축키 검색
            case .alternative:
                
                // 대체 단축키와 비교해서 동일한지 확인
                if willChangeKey == self.alternativeKey && willChangeModifiers == self.alternativeModifiers {
                    // 대체 단축키 카테고리로 반환
                    return (commander: self, category: .alternative)
                }
                
                // 검색하려는 findCommander는 swap이 불가능하고
                // 현재 self(commander)가 swap 가능한 경우
                if findShouldSwap == false && self.shouldSwap == true {
                    // findKey를 전환 키와 비교
                    if willChangeKey == self.swapKey && willChangeModifiers == self.modifiers {
                        // 전환 키 카테고리로 반환
                        return (commander: self, category: .swap)
                    }
                }
                // 검색하려는 findCommander는 alternative가 가능하고
                // 현재 self(commander)가 alternative가 불가능한 경우
                if findShouldAlternative == true && self.shouldAlternative == false {
                    // findeKey를 기본 단축키와 비교
                    if willChangeKey == self.key && willChangeModifiers == self.modifiers {
                        // 일반 키 카테고리로 반환
                        return (commander: self, category: .normal)
                    }
                }
            }
            // 이외의 경우
            return nil
        }
        
        // children 내부 검색 실행
        // 내부 children 순환
        for commander in children {
            guard let result = commander._find(key: willChangeKey, modifiers: willChangeModifiers, of: willChangeCommander, category) else {
                continue
            }
            return result
        }
        // 미발견시 nil 반환
        return nil
    }
    
    /// 특정 Menu에 속한 하위 `EdgeCommander` 셋을 전부 반환
    /// - Parameter menu: `NSMenu`를 지정한다.
    /// - Returns: 주어진 메뉴에 속한 `EdgeCommander` 를 셋으로 반환한다.
    func find(in menu: NSMenu) -> Set<EdgeCommander>? {
        guard let children else { return nil }
        
        var commanders = Set<EdgeCommander>()
        for commander in children {
            // menuItem의 menu를 비교
            if commander.menuItem?.menu == menu {
                commanders.insert(commander)
            }
            
            // commander의 children을 하위 탐색해 추가
            guard let childCommanders = commander.find(in: menu) else {
                continue
            }
            commanders.formUnion(childCommanders)
        }
        guard commanders.isEmpty == false else {
            return nil
        }
        return commanders
    }
}

// MARK: - Extensions for Restore EdgeCommander
extension EdgeCommander {
    
    /// Root EdgeCommander에 복원된 Root EdgeCommander의 값을 적용해 복원한다
    /// - 복원된 Root 커맨더의 key, modifiers, swapKey, canSwap 여부를 적용한다.
    /// - Parameter restoredRootCommander: 복원된 `EdgeCommander`를 지정한다.
    func restore(compareWith restoredRootCommander: EdgeCommander) -> Void {
        // restoredRootCommander가 root 가 아닌 경우 종료
        guard restoredRootCommander.isRoot == true else { return }
        // 설정 복원 실행
        self.restoreSettings(from: restoredRootCommander)
    }
    /// 복원된 `EdgeCommander` 중, 자신과 동일한 `EdgeCommander`를 찾아서 세팅을 복원한다
    /// - action description 기준으로 검색을 실행한다.
    /// - Parameter restoredCommander: 복원된 `EdgeCommander`를 지정한다.
    private func restoreSettings(from restoredCommander: EdgeCommander) -> Void {
        // parent인지 확인
        guard self.isParent == true else {
            // 자기 자신이 commander인 경우
            // 동일한 commander를 복원된 commander에서 검색
            guard let actionDescription = self.actionDescription else { return }
            guard let commander = restoredCommander.find(actionDescription: actionDescription, tag: self.tag) else { return }
            
            if self.key != commander.key { self.key = commander.key }
            if self.tag != commander.tag { self.tag = commander.tag }
            if self.swapKey != commander.swapKey { self.swapKey = commander.swapKey }
            if self.modifiers != commander.modifiers { self.modifiers = commander.modifiers }
            if self.canSwap != commander.canSwap { self.canSwap = commander.canSwap }
            if self.alternativeKey != commander.alternativeKey { self.alternativeKey = commander.alternativeKey }
            if self.alternativeModifiers != commander.alternativeModifiers { self.alternativeModifiers = commander.alternativeModifiers }
            return
        }
        
        // parent인 경우
        guard let children = self.children else { return }
        
        for commander in children {
            commander.restoreSettings(from: restoredCommander)
        }
    }
}

// MARK: - Extensions for Hashable
extension EdgeCommander {
    
    /// 해쉬 값 생성
    public func hash(into hasher: inout Hasher) {
        //hasher.combine(self.action)
        //hasher.combine(self.tag)
        hasher.combine(self.id)
    }
    
    /// 동등성 비교
    public static func == (lhs: EdgeCommander, rhs: EdgeCommander) -> Bool {
        return lhs.id == rhs.id
    }
}
