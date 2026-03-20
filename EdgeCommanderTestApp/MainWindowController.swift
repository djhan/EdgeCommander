//
//  MainWindowController.swift
//  EdgeCommanderTestApp
//

import Cocoa

class MainWindowController: NSWindowController {

    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 240),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "EdgeCommander Test"
        window.center()
        self.init(window: window)
        setupContent()
    }

    private func setupContent() {
        guard let contentView = window?.contentView else { return }

        let label = NSTextField(wrappingLabelWithString:
            "EdgeCommander 테스트 앱입니다.\n\nFile > 환경설정... (⌘,) 에서\n메뉴별 단축키를 설정할 수 있습니다."
        )
        label.font = .systemFont(ofSize: 14)
        label.alignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.widthAnchor.constraint(equalToConstant: 340)
        ])
    }
}
