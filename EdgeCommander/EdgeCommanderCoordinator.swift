//
//  EdgeCommanderCoordinator.swift
//  EdgeCommander
//
//  Created by DJ.HAN on 3/18/26.
//

import Foundation
import Cocoa

import EdgeCommonLib

// MARK: - EdgeCommander Coordinator Class -
@MainActor
public class EdgeCommanderCoordinator {
    
    // MARK: - Static Properties
    /// 싱글톤 선언
    public static let shared = EdgeCommanderCoordinator()

    /// Root Commander
    private var rootCommander: EdgeCommander?
    /// Default Commander
    /// - 기본값으로 설정된 Root Commander 복사본으로, 기본값 복원 시 사용한다.
    private var defaultCommander: EdgeCommander?

    // MARK: - Initializaiton
    /// 초기 셋업
    /// - Important:
    ///   - AppDelegate에서 앱 초기화 시 이 메쏘드를 실행한다.
    ///   - 반드시`EdgeCommanderCoordinator.shared()` 호출 전에 반드시 이 초기 셋업을 실행해야 한다.
    ///   - Root Commander를 복원하려면 환경설정에 저장되어 있던 데이터를 지정한다.
    ///
    /// - Parameters:
    ///   - mainMenu: 메인 메뉴를 지정한다.
    ///   - initializeHandler: EdgeCommander를 초기화할 클로저를 지정한다.
    ///   - restoreData: 복원할 Root Commander의 데이터. 기본값은 널값이다.
    ///   - saveHandler: 환경설정에 데이터를 저장하는 클로저. 기본값은 널값이다.
    public func setup(for mainMenu: NSMenu,
                      _ initializeHandler: @escaping (_ menuItem: NSMenuItem) -> EdgeCommander?,
                      restoreData: Data? = nil,
                      _ saveHandler: ((_ data: Data) -> Bool)? = nil) {
        // Root Commander 초기화.
        rootCommander = EdgeCommander(mainMenu: mainMenu, initializeHandler)
        // 기본값 상태의 Root Commander를 Default Commander로 지정한다.
        defaultCommander = rootCommander?.copy() as? EdgeCommander

        // 설정 복원
        if let restoreData,
           let saveHandler {
            restore(restoreData, saveHandler)
        }
    }

    // MARK: - Methods
    
    // MARK: Update
    /// 전체 단축키 업데이트
    public func updateShortcuts() {
        rootCommander?.updateShortcuts()
    }
    
    // MARK: Swap
    /// 전체 메뉴아이템의 좌우 전환 실행
    /// - 전체 단축키 대상으로 좌우 전환 가능한 키는 모두 전환한다.
    /// - Parameter isSwap: true는 좌우 전환, false는 원래 상태로 복귀한다.
    /// - Returns: 전환 성공 여부 반환.
    @discardableResult
    public func swapHorizontalAll(_ isSwap: Bool) -> Bool {
        guard let rootCommander else {
            EdgeLogger.shared.uiLogger.error("\(#file) > \(#function) :: Root Commander가 없습니다.")
            return false
        }
        return rootCommander.swapHorizontalAll(isSwap)
    }
    /// 전체 메뉴아이템의 상하 전환 실행
    /// - 전체 단축키 대상으로 상하 전환 가능한 키는 모두 전환한다.
    /// - Parameter isSwap: true는 상하 전환, false는 원래 상태로 복귀한다.
    /// - Returns: 전환 성공 여부 반환.
    @discardableResult
    public func swapVerticalAll(_ isSwap: Bool) -> Bool {
        guard let rootCommander else {
            EdgeLogger.shared.uiLogger.error("\(#file) > \(#function) :: Root Commander가 없습니다.")
            return false
        }
        return rootCommander.swapVerticalAll(isSwap)
    }
    /// 특정 메뉴아이템 셋의 좌우 전환
    /// - Parameters:
    ///   - menuItems: 전환할 메뉴아이템 셋을 지정한다.
    ///   - isSwap: 전환 여부를 지정한다.
    /// - Returns: 전환 단축키 적용 여부를 반환한다. 1개라도 전환된 경우엔 true를, 모두 적용에 실패하면 false를 반환한다.
    @discardableResult
    public func swapHorizontal(at menuItems: Set<NSMenuItem>, _ isSwap: Bool) -> Bool {
        guard let rootCommander else {
            EdgeLogger.shared.uiLogger.error("\(#file) > \(#function) :: Root Commander가 없습니다.")
            return false
        }
        return rootCommander.swapHorizontal(at: menuItems, isSwap)
    }
    /// 특정 메뉴아이템 셋의 상하 전환
    /// - Parameters:
    ///   - menuItems: 전환할 메뉴아이템 셋을 지정한다.
    ///   - isSwap: 전환 여부를 지정한다.
    /// - Returns: 전환 단축키 적용 여부를 반환한다. 1개라도 전환된 경우엔 true를, 모두 적용에 실패하면 false를 반환한다.
    @discardableResult
    public func swapVertical(at menuItems: Set<NSMenuItem>, _ isSwap: Bool) -> Bool {
        guard let rootCommander else {
            EdgeLogger.shared.uiLogger.error("\(#file) > \(#function) :: Root Commander가 없습니다.")
            return false
        }
        return rootCommander.swapVertical(at: menuItems, isSwap)
    }
    /// 지정된 액션을 포함하는 하위 메뉴아이템 셋의 좌우 전환
    /// - Parameters:
    ///   - actions: 전환할 액션 셋을 지정한다.
    ///   - isSwap: 전환 여부를 지정한다.
    /// - Returns: 전환 단축키 적용 여부를 반환한다. 1개라도 전환된 경우엔 true를, 모두 적용에 실패하면 false를 반환한다.
    @discardableResult
    public func swapHorizontal(of actions: Set<Selector>, _ isSwap: Bool) -> Bool {
        guard let rootCommander else {
            EdgeLogger.shared.uiLogger.error("\(#file) > \(#function) :: Root Commander가 없습니다.")
            return false
        }
        return rootCommander.swapHorizontal(of: actions, isSwap)
    }
    /// 지정된 액션을 포함하는 하위 메뉴아이템 셋의 상하 전환
    /// - Parameters:
    ///   - actions: 전환할 액션 셋을 지정한다.
    ///   - isSwap: 전환 여부를 지정한다.
    /// - Returns: 전환 단축키 적용 여부를 반환한다. 1개라도 전환된 경우엔 true를, 모두 적용에 실패하면 false를 반환한다.
    @discardableResult
    public func swapVertical(of actions: Set<Selector>, _ isSwap: Bool) -> Bool {
        guard let rootCommander else {
            EdgeLogger.shared.uiLogger.error("\(#file) > \(#function) :: Root Commander가 없습니다.")
            return false
        }
        return rootCommander.swapVertical(of: actions, isSwap)
    }
    
    // MARK: Alternative
    /// 전체 메뉴아이템의 대체 단축키 사용 여부 지정
    /// - Parameter isAlternative: true는 대체 단축키로, false는 원래 상태로 복귀한다.
    /// - Returns: 전환 단축키 적용 여부를 반환한다. 1개라도 전환된 경우엔 true를, 모두 적용에 실패하면 false를 반환한다.
    @discardableResult
    public func setAlternativeAll(_ isAlternative: Bool) -> Bool {
        guard let rootCommander else {
            EdgeLogger.shared.uiLogger.error("\(#file) > \(#function) :: Root Commander가 없습니다.")
            return false
        }
        return rootCommander.setAlternativeAll(isAlternative)
    }
    /// 전체 메뉴아이템의 수평 대체 단축키 전환
    /// - 모든 하위 EdgeCommander를 수평 대체 단축키로 전환한다. 단, 대체 키가 지정된 EdgeCommander만 가능하다.
    /// - Parameter isAlternative: true는 대체 단축키로, false는 원래 상태로 복귀한다.
    /// - Returns: 대체 단축키 적용 여부를 반환한다. 1개라도 전환된 경우엔 true를, 모두 적용에 실패하면 false를 반환한다.
    @discardableResult
    public func setAlternativeHorizontal(_ isAlternative: Bool) -> Bool {
        guard let rootCommander else {
            EdgeLogger.shared.uiLogger.error("\(#file) > \(#function) :: Root Commander가 없습니다.")
            return false
        }
        return rootCommander.setAlternativeHorizontal(isAlternative)
    }
    /// 전체 메뉴아이템의 수직 대체 단축키 전환
    /// - 모든 하위 EdgeCommander를 수직 대체 단축키로 전환한다. 단, 대체 키가 지정된 EdgeCommander만 가능하다.
    /// - Parameter isAlternative: true는 대체 단축키로, false는 원래 상태로 복귀한다.
    /// - Returns: 대체 단축키 적용 여부를 반환한다. 1개라도 전환된 경우엔 true를, 모두 적용에 실패하면 false를 반환한다.
    @discardableResult
    public  func setAlternativeVertical(_ isAlternative: Bool) -> Bool {
        guard let rootCommander else {
            EdgeLogger.shared.uiLogger.error("\(#file) > \(#function) :: Root Commander가 없습니다.")
            return false
        }
        return rootCommander.setAlternativeVertical(isAlternative)
    }
    /// 특정 메뉴아이템 셋의 수평 대체 단축키 전환
    /// - Parameters:
    ///   - menuItems: 전환할 메뉴아이템 셋을 지정한다.
    ///   - isAlternative: true는 대체 단축키로, false는 원래 상태로 복귀한다.
    /// - Returns: 대체 단축키 적용 여부를 반환한다. 1개라도 전환된 경우엔 true를, 모두 적용에 실패하면 false를 반환한다.
    @discardableResult
    func setAlternativeHorizontal(at menuItems: Set<NSMenuItem>, _ isAlternative: Bool) -> Bool {
        guard let rootCommander else {
            EdgeLogger.shared.uiLogger.error("\(#file) > \(#function) :: Root Commander가 없습니다.")
            return false
        }
        return rootCommander.setAlternativeHorizontal(at: menuItems, isAlternative)
    }
    /// 하위 메뉴아이템 셋의 수직 대체 단축키 전환
    /// - Parameters:
    ///   - menuItems: 전환할 메뉴아이템 셋을 지정한다.
    ///   - isAlternative: true는 대체 단축키로, false는 원래 상태로 복귀한다.
    /// - Returns: 대체 단축키 적용 여부를 반환한다. 1개라도 전환된 경우엔 true를, 모두 적용에 실패하면 false를 반환한다.
    @discardableResult
    public func setAlternativeVertical(at menuItems: Set<NSMenuItem>, _ isAlternative: Bool) -> Bool {
        guard let rootCommander else {
            EdgeLogger.shared.uiLogger.error("\(#file) > \(#function) :: Root Commander가 없습니다.")
            return false
        }
        return rootCommander.setAlternativeVertical(at: menuItems, isAlternative)
    }
    
    // MARK: - Find Commander
    /// 특정 Menu의 하위 Commander 셋을 전부 반환
    /// - Parameter menu: 찾으려는 메뉴.
    /// - Returns: EdgeCommander 셋을 반환한다. 해당 메뉴에 EdgeCommander가 없다면 널값이 반환된다.
    public func find(in menu: NSMenu) -> Set<EdgeCommander>? {
        return self.rootCommander?.find(in: menu)
    }
    /// 특정 `NSMenuItem`을 격납한 `Commander` 반환
    /// - Parameter menuItem: 찾으려는 메뉴아이템.
    /// - Returns: 해당 메뉴아이템을 격납한 EdgeCommander을 반환한다. 없는 경우 널값을 반환한다.
    public func find(menuItem: NSMenuItem) -> EdgeCommander? {
        return self.rootCommander?.find(menuItem: menuItem)
    }
    /// 특정 `Selector`를 가진 `Commander` 셋을 반환한다
    /// - Important: tag가 다른 `Commander`들이 있는 경우, 모두 찾아서 셋으로 묶어 반환한다.
    /// - Parameter action: 찾으려는 `Selector`를 지정한다.
    /// - Returns: 검색한 `Commander`를 셋으로 반환한다.
    public func find(action: Selector) -> Set<EdgeCommander>? {
        return self.rootCommander?.find(action: action)
    }
    /// 특정 action description 및 tag와 일치하는 EdgeCommander 반환 메쏘드
    /// - Parameters:
    ///   - actionDescription: 검색할 action description 문자열.
    ///   - tag: 검색할 태그 값. 널값 지정 시 태그 검색은 생략한다.
    /// - Returns: 발견 시 해당 `Commander`를 반환하고, 미발견 시 널값을 반환한다.
    public func find(actionDescription: String, tag: Int) -> EdgeCommander? {
        return self.rootCommander?.find(actionDescription: actionDescription, tag: tag)
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
    public func find(key: String,
                     modifierFlags: NSEvent.ModifierFlags) -> EdgeCommander? {
        return self.rootCommander?.find(key: key, modifierFlags: modifierFlags)
    }
    /// 특정 단축키 조합과 일치하는 하위 EdgeCommander 반환
    /// - Important:
    ///   - findCommander가 다른 EdgeCommander 단축키와와 충돌하는지 여부를 탐색하는 것이 목적이다.
    ///   - 즉, 단축키 조합을 변경하려 할 때, 변경하려는 조합과 일치하는 EdgeCommander가 있는지 여부를 확인하는 용도로 사용한다.
    ///   - 현재는 Internal 메쏘드로 사용한다.
    /// - Parameters:
    ///   - willChangeKey: 키 값을 지정한다.
    ///   - willChangeModifiers: 보조 키를 `EdgeCommander.Modifier`의 셋으로 지정한다. 널값 지정이 가능하다.
    ///   - willChangeCommander: 비교하려는 `EdgeCommander`를 지정한다.
    ///   - category: 비교하려는 카테고리(일반 키 / 전환 키 / 대체 키).
    /// - Returns: EdgeCommander 및 검색 결과 종류(일반 키 / 대체 키 구분)를 `FoundCommanderResult`로 반환한다. 없는 경우 널값을 반환한다.
    func find(key willChangeKey: String,
              modifiers willChangeModifiers: Set<EdgeCommander.Modifier>?,
              of willChangeCommander: EdgeCommander,
              _ category: EdgeCommander.Category) -> FoundCommander? {
        return self.rootCommander?.find(key: willChangeKey, modifiers: willChangeModifiers, of: willChangeCommander, category)
    }

    // MARK: - Encoder
    /// 현재 Root Commander를 Data 형태로 반환해 저장한다
    /// - Important:
    ///   - Preference 키 값으로 현재 단축키 설정을 저장하기 위해 사용한다.
    ///   - saveHandler에 환경설정에 데이터를 저장하는 루틴을 작성해야 한다.
    /// - Parameter saveHandler: 환경설정에 데이터를 저장하는 클로저.
    /// - Returns: 성공 여부를 반환한다.
    @discardableResult
    public func save(_ saveHandler: @escaping (_ data: Data) -> Bool) -> Bool {
        let encoder = PropertyListEncoder()
        guard let rootCommander,
              let data = try? encoder.encode(rootCommander) else {
            EdgeLogger.shared.uiLogger.error("\(#file):\(#function) :: Root Commander가 없거나 데이터 변환에 실패했습니다.")
            return false
        }
        
        return saveHandler(data)
    }
    
    /// Root Commander를 주어진 Data에서 복구한다
    /// - Important: 저장된 Data에서 Root Commander를 복구하며, 보통 앱 초기 런칭 시에 1회 실행된다. 복구와 동시에 환경설정에 저장한다.
    /// - Parameters:
    ///   - data: 복구할 데이터.
    ///   - saveHandler: saveHandler: 환경설정에 데이터를 저장하는 클로저.
    /// - Returns: 성공 여부를 반환한다.
    @discardableResult
    public func restore(_ data: Data,
                        _ saveHandler: @escaping (_ data: Data) -> Bool) -> Bool {
        // 현재 Root Commander 확인
        guard let rootCommander else {
            // 없는 경우 종료 처리
            return false
        }
        
        let decoder = PropertyListDecoder()
        guard let restoredRootCommander = try? decoder.decode(EdgeCommander.self, from: data) else {
            EdgeLogger.shared.uiLogger.error("\(#file):\(#function) :: Root Commander 복원에 실패했습니다.")
            // 복원할 Commander가 없는 경우, 현재 Root Commander를 저장한다
            save(saveHandler)
            // 실패 반환
            return false
        }
        // 복원 실행
        rootCommander.restore(compareWith: restoredRootCommander)
        // 복원 후 저장 처리
        return save(saveHandler)
    }
    
    /// Root Commander를 기본값으로 복구한다.
    /// - Important:
    ///   - removeAllHandler에 환경설정에 저장된 전체 단축키를 삭제하는 루틴을 작성해야 한다.
    /// - Parameter removeAllHandler: 환경설정에 저장된 전체 단축키를 삭제하는 클로저.
    /// - Returns: 성공 여부를 반환한다.
    @discardableResult
    public func restoreDefault(_ removeAllHandler: @escaping () -> Void) -> Bool {
        // 현재 Root Commander 와 Default Commander를 확인
        guard let rootCommander,
              let defaultCommander else {
            EdgeLogger.shared.uiLogger.error("\(#file):\(#function) :: Root Commander 기본값 복원에 실패했습니다.")
            // 없는 경우 종료 처리
            return false
        }

        // 환경설정에서 값 제거 실행
        removeAllHandler()
        // 기본값 복원
        rootCommander.restore(compareWith: defaultCommander)
        return true
    }

}

// MARK: - Extension for Collection
extension EdgeCommanderCoordinator: @MainActor Collection {
    
    /// Children 갯수 반환
    public var count: Int {
        return self.rootCommander?.count ?? 0
    }
    
    public func index(after i: Int) -> Int {
        return i + 1
    }
    public var startIndex: Int {
        return 0
    }
    public var endIndex: Int {
        return self.count
    }
    public subscript(index: Int) -> EdgeCommander? {
        guard 0 ..< endIndex ~= index else {
            return nil
        }
        return self.rootCommander?[index]
    }
}
