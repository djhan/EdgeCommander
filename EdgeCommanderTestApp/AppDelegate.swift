//
//  AppDelegate.swift
//  EdgeCommanderTestApp
//

import Cocoa
import EdgeCommander

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.run()
    }

    var mainWindowController: MainWindowController?
    var preferencesWindowController: PreferencesWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        print("✅ applicationDidFinishLaunching called")
        
        // 0. Activation Policy 설정 (프로그래매틱 UI용)
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        // 1. 메뉴 구성
        setupMenus()

        // 2. 메인 윈도우 표시
        mainWindowController = MainWindowController()
        mainWindowController?.showWindow(nil)

        // 3. EdgeCommanderCoordinator 설정 (메뉴 구성 이후 실행)
        guard let mainMenu = NSApp.mainMenu else { return }
        CommanderCoordinator.shared.setup(for: mainMenu) { menuItem in
            let key = menuItem.keyEquivalent.isEmpty ? nil : menuItem.keyEquivalent
            let modifiers = menuItem.keyEquivalent.isEmpty ? nil : menuItem.keyEquivalentModifierMask
            return Commander(menuItem, key: key, modifierFlags: modifiers)
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    // MARK: - Menu Setup

    private func setupMenus() {
        let mainMenu = NSMenu()
        NSApp.mainMenu = mainMenu

        // Apple 메뉴
        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)
        let appMenu = NSMenu()
        appMenuItem.submenu = appMenu
        appMenu.addItem(NSMenuItem(
            title: "EdgeCommanderTestApp 종료",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        ))

        // File 메뉴
        let fileMenuItem = NSMenuItem()
        mainMenu.addItem(fileMenuItem)
        let fileMenu = NSMenu(title: "File")
        fileMenuItem.submenu = fileMenu
        fileMenu.addItem(NSMenuItem(
            title: "열기",
            action: #selector(AppDelegate.openDocument(_:)),
            keyEquivalent: "o"
        ))
        fileMenu.addItem(NSMenuItem(
            title: "닫기",
            action: #selector(NSWindow.performClose(_:)),
            keyEquivalent: "w"
        ))
        fileMenu.addItem(.separator())
        let prefsItem = NSMenuItem(
            title: "환경설정...",
            action: #selector(AppDelegate.openPreferences(_:)),
            keyEquivalent: ","
        )
        prefsItem.keyEquivalentModifierMask = .command
        fileMenu.addItem(prefsItem)

        // Edit 메뉴
        let editMenuItem = NSMenuItem()
        mainMenu.addItem(editMenuItem)
        let editMenu = NSMenu(title: "Edit")
        editMenuItem.submenu = editMenu
        editMenu.addItem(NSMenuItem(
            title: "잘라내기",
            action: #selector(NSText.cut(_:)),
            keyEquivalent: "x"
        ))
        editMenu.addItem(NSMenuItem(
            title: "복사",
            action: #selector(NSText.copy(_:)),
            keyEquivalent: "c"
        ))
        editMenu.addItem(NSMenuItem(
            title: "붙여넣기",
            action: #selector(NSText.paste(_:)),
            keyEquivalent: "v"
        ))
        editMenu.addItem(.separator())
        editMenu.addItem(NSMenuItem(
            title: "모두 선택",
            action: #selector(NSText.selectAll(_:)),
            keyEquivalent: "a"
        ))
    }

    // MARK: - Actions

    @objc func openDocument(_ sender: Any?) {
        // 테스트용 - 실제 동작 없음
    }

    @objc func openPreferences(_ sender: Any?) {
        if preferencesWindowController == nil {
            preferencesWindowController = PreferencesWindowController()
        }
        preferencesWindowController?.showWindow(nil)
        preferencesWindowController?.window?.makeKeyAndOrderFront(nil)
    }
}
