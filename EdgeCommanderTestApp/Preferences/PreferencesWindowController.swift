//
//  PreferencesWindowController.swift
//  EdgeCommanderTestApp
//

import Cocoa

class PreferencesWindowController: NSWindowController {

    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 580, height: 420),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "환경설정"
        window.center()
        window.minSize = NSSize(width: 480, height: 300)
        self.init(window: window)

        window.contentViewController = ShortcutsViewController()
    }
}

