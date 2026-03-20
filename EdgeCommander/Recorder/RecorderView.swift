//
//  RecorderView.swift
//  EdgeCommander
//
//  Created by DJ.HAN on 3/19/26.
//

import Foundation
import Cocoa

import EdgeCommonLib

// MARK: - Recorder Delegate Protocol -
/// Recoder Delegate Protccol
/// - Recodrder 입력 완료 여부를 파악해 메뉴 및 화면 리로딩을 구현하는 데 사용되는 프로토콜로, Recoder를 호출하는 부모 뷰, 또는 부모 뷰 컨트롤러를 지정한다.
public protocol RecorderViewDelegate: AnyObject {
    /// 단축키 입력 개시 여부
    func recorderViewShouldBeginRecording(_ recorderView: RecorderView) -> Bool
    /// 단축키 입력 가능 여부
    func recorderView(_ recorderView: RecorderView, canRecord commander: Commander) -> Bool
    /// 단축키 변경 여부
    func recorderView(_ recorderView: RecorderView, didChange commander: Commander?)
    /// 단축키 입력 완료 여부
    func recorderViewDidEndRecording(_ recorderView: RecorderView)
}

/// Recorder View Class
@IBDesignable
@MainActor
public class RecorderView: NSView {

    // MARK: - Properties
    @IBInspectable open var backgroundColor: NSColor = .controlColor {
        didSet { layer?.backgroundColor = backgroundColor.cgColor }
    }
    @IBInspectable open var tintColor: NSColor = .controlAccentColor {
        didSet { needsDisplay = true }
    }
    @IBInspectable open var borderColor: NSColor = .controlColor {
        didSet { layer?.borderColor = borderColor.cgColor }
    }
    @IBInspectable open var borderWidth: CGFloat = 0 {
        didSet { layer?.borderWidth = borderWidth }
    }
    @IBInspectable open var cornerRadius: CGFloat = 0 {
        didSet {
            layer?.cornerRadius = cornerRadius
            noteFocusRingMaskChanged()
        }
    }
    public var clearButtonMode: RecorderView.ClearButtonMode = .always {
        didSet { needsDisplay = true }
    }

    public weak var delegate: RecorderViewDelegate?
    public var didChange: ((Commander?) -> Void)?
    @objc dynamic open private(set) var isRecording = false
    
    /// Commander 프로퍼티
    /// - 변경될 Commander 를 저장하는 Weak 프로퍼티.
    public weak var commander: Commander? = nil {
        // Commander 지정 완료시
        didSet {
            // 단축키 클리어 버튼 표시 여부 확인
            switch self.canClear {
            // 표시 가능시
            case true:
                // 이미 표시중인지 확인
                guard let clearButton,
                      self.subviews.contains(clearButton) == false else {
                    return
                }
                self.addSubview(clearButton)
                
            // 표시 불가시
            case false:
                clearButton?.removeFromSuperview()
            }
            clearButton?.isHidden = !self.canClear

            // 리드로잉
            self.needsDisplay = true
        }
    }
    
    /// 키 입력 종류
    public var category: Commander.Category = .normal
    
    public var isEnabled = true {
        didSet {
            self.needsDisplay = true
            if !isEnabled { endRecording() }
            noteFocusRingMaskChanged()
        }
    }

    private var clearButton: NSButton?
    private let validModifierFlags: [NSEvent.ModifierFlags] = [.function, .shift, .control, .option, .command]
    private let validModifiersFlagsText: [NSString] = ["fn", "⇧", "⌃", "⌥", "⌘"]
    private var inputModifierFlags = NSEvent.ModifierFlags()
    private var fontSize: CGFloat {
        return bounds.height / 1.7
    }
    private var clearSize: CGFloat {
        return fontSize / 1.3
    }
    private var marginY: CGFloat {
        return (bounds.height - fontSize) / 2.6
    }
    private var marginX: CGFloat {
        return marginY * 1.6
    }
    private var isFirstResponder: Bool {
        return (isEnabled && window?.firstResponder == self && isRecording)
    }

    // MARK: - Override Properties
    open override var isOpaque: Bool {
        return false
    }
    open override var isFlipped: Bool {
        return true
    }
    open override var focusRingMaskBounds: NSRect {
        return (isFirstResponder) ? bounds : NSRect.zero
    }

    // MARK: - Initialize
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        initView()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initView()
    }

    private func initView() {
        // Layer
        wantsLayer = true
        layer?.backgroundColor = backgroundColor.cgColor
        layer?.borderColor = borderColor.cgColor
        layer?.borderWidth = borderWidth
        layer?.cornerRadius = cornerRadius
        
        // Clear Button
        clearButton = NSButton()
        guard let clearButton else {
            return
        }
        let config = NSImage.SymbolConfiguration(pointSize: self.clearSize, weight: .bold)
        clearButton.image = NSImage(systemSymbolName: "xmark.circle", accessibilityDescription: String(localized: "Clear"))?.withSymbolConfiguration(config)
        clearButton.bezelStyle = .circular
        clearButton.isBordered = false
        clearButton.target = self
        clearButton.action = #selector(RecorderView.clearAndEndRecording)
        addSubview(clearButton)
    }

    // MARK: - Draw
    open override func drawFocusRingMask() {
        guard isFirstResponder else { return }
        NSBezierPath(roundedRect: bounds, xRadius: cornerRadius, yRadius: cornerRadius).fill()
    }

    open override func draw(_ dirtyRect: NSRect) {
        layer?.backgroundColor = backgroundColor.cgColor
        layer?.borderColor = borderColor.cgColor
        // 일반 단축키 입력 / 대체 키 입력인 경우 modifier key 영역 드로잉
        if self.category == .normal || self.category == .alternative {
            drawModifiers(dirtyRect)
        }
        drawKeyCode(dirtyRect)
        drawClearButton(dirtyRect)
    }

    private func drawModifiers(_ dirtyRect: NSRect) {
        let fontSize = self.fontSize
        var modifiers: NSEvent.ModifierFlags
        
        // 카테고리별로 드로잉
        switch self.category {
        // 일단 단축키
        case .normal:
            modifiers = self.commander?.modifierFlags ?? inputModifierFlags
        // 전환 키: 이 경우는 아무런 단축키도 표시하지 않는다
        case .swap:
            modifiers = NSEvent.modifierFlags
        // 대체 단축키
        case .alternative:
            modifiers = self.commander?.alternativeModifierFlags ?? inputModifierFlags
        }
        for (i, text) in validModifiersFlagsText.enumerated() {
            let rect = NSRect(x: marginX + (fontSize * CGFloat(i)), y: marginY, width: fontSize, height: bounds.height)
            text.draw(in: rect, withAttributes: modifierTextAttributes(modifiers, checkModifier: validModifierFlags[i]))
        }
    }

    private func drawKeyCode(_ dirtyRext: NSRect) {
        guard let commander = self.commander else { return }
        let fontSize = self.fontSize
        let minX = (fontSize * 5) + (marginX * 2)
        let width = bounds.width - minX - (marginX * 2) - clearSize
        guard width > 0 else { return }
        var text: String
        switch self.category {
        // 일반 조합키
        case .normal: text = commander.key?.readable ?? ""
        // 상하/좌우 전환키
        case .swap: text = commander.swapKey?.readable ?? ""
        // 대체 키
        case .alternative: text = commander.alternativeKey?.readable ?? ""
        }
        text.draw(in: NSRect(x: minX, y: marginY, width: width, height: bounds.height), withAttributes: keyCodeTextAttributes())
    }

    private func drawClearButton(_ dirtyRext: NSRect) {
        let clearSize = self.clearSize
        let x = bounds.width - clearSize - marginX
        let y = (bounds.height - clearSize) / 2
        clearButton?.frame = NSRect(x: x, y: y, width: clearSize, height: clearSize)
        switch clearButtonMode {
        case .always: clearButton?.isHidden = false
        case .never: clearButton?.isHidden = true
        case .whenRecorded: clearButton?.isHidden = (self.commander == nil)
        }
    }

    // MARK: - NSResponder
    open override var acceptsFirstResponder: Bool {
        return isEnabled
    }

    open override var canBecomeKeyView: Bool {
        return super.canBecomeKeyView && NSApp.isFullKeyboardAccessEnabled
    }

    open override var needsPanelToBecomeKey: Bool {
        return true
    }

    open override func becomeFirstResponder() -> Bool {
        return focusView()
    }

    open override func resignFirstResponder() -> Bool {
        unfocusView()
        //print("RecoderView>resignFirstResponder:")
        return super.resignFirstResponder()
    }

    open override func cancelOperation(_ sender: Any?) {
        endRecording()
    }

    open override func keyDown(with theEvent: NSEvent) {
        guard !performKeyEquivalent(with: theEvent) else { return }
        super.keyDown(with: theEvent)
    }

    /**
     키 입력
     - NSEvent의 keycode 기반으로 키값을 생성. [참고 링크] (http://vak.ru/doku.php/proj/macosx/function-keys)
     */
    open override func performKeyEquivalent(with theEvent: NSEvent) -> Bool {
        guard isFirstResponder else { return false }
        guard let commander = self.commander else { return false }
        
        // 현재 commander가 이동 키로만 구성되었는지 확인
        let wasOnlyMovableKey = commander.isOnlyMovableKey
        // alternative 키 제거 여부
        var willRemoveAlternativeKey = false
        
        // NSEvent의 keycode 기반으로 키값을 생성
        guard let key = theEvent.keyCode.commanderKey else { return false }
        let modifierFlags = theEvent.filterUnsupportModifierFlags() //theEvent.modifierFlags.filterUnsupportModifierFlags()
        // Modifer Set으로 변환
        let modifiers = modifierFlags.toModifiers()

        //---------------------------------------------------------------------//
        /// `Commander`의 업데이트를 처리, 고지하는 내부 메쏘드
        func didChange(_ commander: Commander) {
            self.didChange?(commander)
            delegate?.recorderView(self, didChange: commander)
        }
        //---------------------------------------------------------------------//

        //---------------------------------------------------------------------//
        /// 현재 Commander 키/편집 키/전환키를 업데이트하는 내부 메쏘드
        @discardableResult
        func updateCommander() -> Bool {
            switch self.category {
            // 일반 단축키 입력
            case .normal:
                commander.modifiers = modifiers
                commander.key = key
                
                if willRemoveAlternativeKey == true {
                    commander.alternativeKey = nil
                    commander.alternativeModifiers = nil
                }
                
            // 좌우 전환 키 입력
            case .swap:
                // Modifier 변경 없이, swapKey에 key값 대입
                commander.swapKey = key
                
            // 대체 키 입력
            case .alternative:
                commander.alternativeModifiers = modifiers
                commander.alternativeKey = key
            }
            
            didChange(commander)
            endRecording()
            return true
        }
        //---------------------------------------------------------------------//

        // 전환키인 경우, modifiers를 현재 commander의 modifiers로 대체
        let findModifiers = self.category == .swap ? commander.modifiers : modifiers
        // 검색 결과
        let foundResult = CommanderCoordinator.shared.find(key: key, modifiers: findModifiers, of: commander, self.category)
        
        // 일반 단축키 입력시
        // 이동 키만 있는 경우 -> 일반적인 단축키로 변경되었는지 확인
        if self.category == .normal,
           wasOnlyMovableKey == true,
           theEvent.isOnlyMovementKey == false,
           commander.alternativeKey != nil {
            
            // 일반 단축키로 변경시, alternative 키 제거 경고
            
            // NSAlert 생성
            let alert = NSAlert()
            // 주 경고 메시지
            alert.messageText = String(localized: "Change to normal shortcut.")
            // 설명
            alert.informativeText = String(localized: "\(commander.title) is change to normal shortcut. Alternative key will be clear.")

            // 제 1버튼:
            alert.addButton(withTitle: String(localized: "OK"))
            // 제 2버튼: 마지막 페이지 이동
            alert.addButton(withTitle: String(localized: "Cancel"))

            let response = alert.runModal()
            
            guard response == .alertFirstButtonReturn else {
                // 취소시 레코딩 종료
                endRecording()
                return false
            }
            
            willRemoveAlternativeKey = true
        }
        
        // scope 종료시
        defer {
            // 일반 단축키 입력시
            if self.category == .normal {
                // 이동 키만 있는지 확인
                // - 이동 키만 있는 경우, 경고창 표시
                self.checkIsOnlyMovementKey(commander)
            }
        }
                
        // 단축키와 충돌하는 commander가 있는지 확인
        // 현재 변경하려는 commander와 동일한 경우는 무시
        guard let existCategory = foundResult?.category,
            let existCommander = foundResult?.commander,
            existCommander != commander else {
            // 단축키와 충돌하는 commander 미발견시, 업데이트 실행후 결과 반환
            return updateCommander()
        }
        
        // 이미 해당 단축키가 존재하는 경우

        guard let window = self.window else { return false }

        // NSAlert 생성
        let alert = NSAlert()
        
        var informativeText: String
        switch self.category {
        // 일반 단축키 입력
        case .normal:
            // 주 경고 메시지
            alert.messageText = String(localized: "Same shortcut is already exist.")
            // 설명
            let shortcutReadable = Commander.shortcutReadable(modifiers: modifiers, key: key)
            informativeText = String(localized: "\(shortcutReadable) is used for \(existCommander.title).\r")
            
        // 전환 키 입력
        case .swap:
            // 주 경고 메시지
            alert.messageText = String(localized: "Same swap key is already exist.")
            // 설명
            let shortcutReadable = commander.modifiers != nil ? Commander.shortcutReadable(modifiers: commander.modifiers!, key: key) : key.readable
            informativeText = String(localized: "Swapped shortcut \(shortcutReadable) is used for \(existCommander.title).\r")
            
        // 대체 키 입력
        case .alternative:
            // 주 경고 메시지
            alert.messageText = String(localized: "Same alternative key is already exist.")
            // 설명
            let shortcutReadable = commander.alternativeModifiers != nil ? Commander.shortcutReadable(modifiers: commander.alternativeModifiers!, key: key) : key.readable
            informativeText = String(localized: "Alternative shortcut \(shortcutReadable) is used for \(existCommander.title).\r)")
        }
        // 설명 텍스트 대입
        alert.informativeText = informativeText + String(localized: "Do you want to use this shortcut for \(commander.title)?")
        
        // 제 1버튼:
        alert.addButton(withTitle: String(localized: "OK"))
        // 제 2버튼: 마지막 페이지 이동
        alert.addButton(withTitle: String(localized: "Cancel"))
        // 제 1 버튼에 리턴 키 할당
        alert.buttons[0].keyEquivalent = Commander.SpecialKey.return.rawValue
        // 제 2 버튼(취소)에 Escape 키 할당
        alert.buttons[1].keyEquivalent = Commander.SpecialKey.escape.rawValue
        
        // 경고음
        NSSound.beep()
        
        alert.beginSheetModal(for: window) { [weak self] (response: NSApplication.ModalResponse) in
            guard let strongSelf = self else { return }

            // 버튼에 따라 다른 결과 반환
            switch response {
            // 최초 버튼 클릭시 (OK 버튼)
            case .alertFirstButtonReturn:
                // 기존 Commander의 단축키 / 전환키 제거
                
                // 동일 항목 결과 확인
                switch existCategory {
                // 일반 단축키
                case .normal:
                    // 단축키 및 편집키를 모두 제거
                    existCommander.key = nil
                    existCommander.modifiers = nil

                // 좌우 전환키
                case .swap:
                    // 기존 commander의 좌우 전환 키 제거
                    existCommander.swapKey = nil

                // 대체 키
                case .alternative:
                    // 기존 commander의 대체 키 및 대체 편지키를 모두 제거
                    existCommander.alternativeKey = nil
                    existCommander.alternativeModifiers = nil
                }

                // existCommander 변경 완료
                didChange(existCommander)
                // 업데이트 실행
                updateCommander()
                
            // 두번째 버튼 클릭시 (취소 버튼)
            // 또는, 그 외의 경우
            default:
                // 화면 리로딩
                strongSelf.needsDisplay = true
                // 종료. 이후 새로운 키 입력을 대기...
                return
            }
        }
        
        return true
    }

    /// 이동 키만 입력된 경우인지 확인
    /// - 이동 키만 입력된 경우 경고창을 표시한다.
    /// - Parameter commander: 단축 키를 확인하려는 `Commander`.
    private func checkIsOnlyMovementKey(_ commander: Commander) {
        
        guard commander.isOnlyMovableKey == true else {
            return
        }

        // NSAlert 생성
        let alert = NSAlert()

        // 제 1버튼:
        alert.addButton(withTitle: String(localized: "OK"))
        // 제 1 버튼에 리턴 키 할당
        alert.buttons[0].keyEquivalent = Commander.SpecialKey.return.rawValue
        // 주 경고 메시지
        alert.messageText = String(localized: "Only Movement Key was set.")
        // 설명
        alert.informativeText = String(localized: "Only movement key was set for \(commander.title). You can set alternative shortcut key, too.")

        alert.runModal()
    }
    
    
    open override func flagsChanged(with theEvent: NSEvent) {
        guard isFirstResponder else {
            inputModifierFlags = NSEvent.ModifierFlags()
            needsDisplay = true
            super.flagsChanged(with: theEvent)
            return
        }
        inputModifierFlags = theEvent.modifierFlags
        needsDisplay = true
        super.flagsChanged(with: theEvent)
    }

}

// MARK: - Text Attributes
private extension RecorderView {
    func modifierTextAttributes(_ modifiers: NSEvent.ModifierFlags, checkModifier: NSEvent.ModifierFlags) -> [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.baseWritingDirection = .leftToRight
        let textColor: NSColor
        if !isEnabled {
            textColor = .disabledControlTextColor
        } else if modifiers.contains(checkModifier) {
            textColor = tintColor
        } else {
            textColor = .lightGray
        }
        return [.font: NSFont.systemFont(ofSize: floor(fontSize)),
                .foregroundColor: textColor,
                .paragraphStyle: paragraphStyle]
    }

    func keyCodeTextAttributes() -> [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.baseWritingDirection = .leftToRight
        let textColor: NSColor
        if !isEnabled {
            textColor = .disabledControlTextColor
        } else {
            textColor = tintColor
        }
        return [.font: NSFont.systemFont(ofSize: floor(fontSize)),
                .foregroundColor: textColor,
                .paragraphStyle: paragraphStyle]
    }
}

// MARK: - Recording
extension RecorderView {
    @discardableResult
    public func beginRecording() -> Bool {
        guard let window = self.window else { return false }
        guard isEnabled else { return false }
        guard window.firstResponder != self || !isRecording else { return true }
        return window.makeFirstResponder(self)
    }

    @discardableResult
    public func endRecording() -> Bool {
        guard let window = self.window else { return true }
        guard window.firstResponder == self || isRecording else { return true }
        return window.makeFirstResponder(nil)
    }

    private func focusView() -> Bool {
        guard isEnabled else { return false }
        if let delegate = delegate, !delegate.recorderViewShouldBeginRecording(self) {
            NSSound.beep()
            //print("RecoderView>focusView: 실패 처리")
            return false
        }
        isRecording = true
        needsDisplay = true
        updateTrackingAreas()
        //print("RecoderView>focusView:")
        return true
    }

    private func unfocusView() {
        inputModifierFlags = NSEvent.ModifierFlags()
        isRecording = false
        updateTrackingAreas()
        needsDisplay = true
        delegate?.recorderViewDidEndRecording(self)
        //print("RecoderView>unfocusView:")
    }
}

// MARK: - Clear Keys
extension RecorderView {
    /// 제거 가능한 단축키가 있는지 확인
    public var canClear: Bool {
        guard let commander = self.commander else {
            return false
        }
        switch self.category {
        // 일반 단축키 입력시
        case .normal:
            guard commander.key != nil else {
                return false
            }

        // 전환 키 입력시
        case .swap:
            guard commander.swapKey != nil else {
                return false
            }
            
        // 대체 키 입력시
        case .alternative:
            guard commander.alternativeKey != nil else {
                return false
            }
        }
        
        // 이외의 경우, 제거 가능으로 판별
        return true
    }
    
    /// 단축키 제거
    @objc public func clear() {
        /*
        commander = nil
        inputModifierFlags = NSEvent.ModifierFlags()
        needsDisplay = true
        didChange?(nil)
        delegate?.recorderView(self, didChange: nil)*/
        
        switch self.category {
        // 일반 단축키 입력시
        case .normal:
            self.commander?.key = nil
            self.commander?.modifiers = nil

        // 전환 키 입력시
        case .swap:
            self.commander?.swapKey = nil
            
        // 대체 키 입력시
        case .alternative:
            self.commander?.alternativeKey = nil
            self.commander?.alternativeModifiers = nil
        }
        needsDisplay = true
        didChange?(self.commander)
        delegate?.recorderView(self, didChange: self.commander)
    }
    /// 단축키 제거 + 레코딩 종료
    @objc func clearAndEndRecording() {
        clear()
        endRecording()
    }
}

// MARK: - Clear Button Mode
extension RecorderView {
    public enum ClearButtonMode {
        case never
        case always
        case whenRecorded
    }
}

