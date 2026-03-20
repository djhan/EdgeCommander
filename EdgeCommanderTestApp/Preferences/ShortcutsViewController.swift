//
//  ShortcutsViewController.swift
//  EdgeCommanderTestApp
//

import Cocoa
import EdgeCommander

// MARK: - ShortcutsViewController

class ShortcutsViewController: NSViewController {

    private var scrollView: NSScrollView!
    private var outlineView: NSOutlineView!
    private weak var activeRecorderView: RecorderView?

    // MARK: - View Lifecycle

    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 580, height: 420))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupOutlineView()
        setupButtons()
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        // 화면 표시 시점에 데이터 갱신 (CommanderCoordinator 초기화 이후)
        outlineView.reloadData()
        expandAllGroups()
    }

    // MARK: - Setup

    private func setupOutlineView() {
        scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.borderType = .bezelBorder
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        outlineView = NSOutlineView()
        outlineView.style = .inset
        outlineView.rowSizeStyle = .default
        outlineView.allowsColumnReordering = false
        outlineView.allowsMultipleSelection = false
        outlineView.doubleAction = #selector(rowDoubleClicked)
        outlineView.target = self
        outlineView.dataSource = self
        outlineView.delegate = self

        // 메뉴명 컬럼
        let titleColumn = NSTableColumn(identifier: .init("Title"))
        titleColumn.title = "메뉴명"
        titleColumn.width = 200
        titleColumn.minWidth = 100
        outlineView.addTableColumn(titleColumn)
        outlineView.outlineTableColumn = titleColumn

        // 단축키 컬럼
        let shortcutColumn = NSTableColumn(identifier: .init("Shortcut"))
        shortcutColumn.title = "단축키"
        shortcutColumn.width = 320
        shortcutColumn.minWidth = 200
        outlineView.addTableColumn(shortcutColumn)

        scrollView.documentView = outlineView

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -52)
        ])
    }

    private func setupButtons() {
        let okButton = NSButton(title: "확인", target: self, action: #selector(okButtonClicked))
        okButton.bezelStyle = .rounded
        okButton.keyEquivalent = "\r"
        okButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(okButton)

        let cancelButton = NSButton(title: "취소", target: self, action: #selector(cancelButtonClicked))
        cancelButton.bezelStyle = .rounded
        cancelButton.keyEquivalent = "\u{1b}"
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cancelButton)

        NSLayoutConstraint.activate([
            okButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            okButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12),
            okButton.widthAnchor.constraint(equalToConstant: 80),

            cancelButton.trailingAnchor.constraint(equalTo: okButton.leadingAnchor, constant: -8),
            cancelButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12),
            cancelButton.widthAnchor.constraint(equalToConstant: 80)
        ])
    }

    // MARK: - Helpers

    private func expandAllGroups() {
        for i in 0..<CommanderCoordinator.shared.count {
            guard let commander = CommanderCoordinator.shared[i] else { continue }
            outlineView.expandItem(commander)
        }
    }

    private func commander(atRow row: Int) -> Commander? {
        return outlineView.item(atRow: row) as? Commander
    }

    // MARK: - Actions

    @objc private func rowDoubleClicked() {
        let row = outlineView.clickedRow
        guard row >= 0,
              let commander = commander(atRow: row),
              commander.isLeaf else { return }

        // 기존 RecorderView 종료
        activeRecorderView?.endRecording()

        let shortcutColumnIndex = outlineView.column(withIdentifier: .init("Shortcut"))
        guard shortcutColumnIndex >= 0,
              let cellView = outlineView.view(atColumn: shortcutColumnIndex, row: row, makeIfNecessary: false) as? ShortcutCellView
        else { return }

        cellView.recorderView.beginRecording()
        activeRecorderView = cellView.recorderView
    }

    @objc private func okButtonClicked() {
        activeRecorderView?.endRecording()
        CommanderCoordinator.shared.updateShortcuts()
        view.window?.close()
    }

    @objc private func cancelButtonClicked() {
        activeRecorderView?.endRecording()
        view.window?.close()
    }
}

// MARK: - NSOutlineViewDataSource

extension ShortcutsViewController: NSOutlineViewDataSource {

    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return CommanderCoordinator.shared.count
        }
        return (item as? Commander)?.children?.count ?? 0
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            return CommanderCoordinator.shared[index] as Any
        }
        guard let commander = item as? Commander,
              let children = commander.children else { return NSNull() }
        return children[index]
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return (item as? Commander)?.isParent ?? false
    }
}

// MARK: - NSOutlineViewDelegate

extension ShortcutsViewController: NSOutlineViewDelegate {

    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let commander = item as? Commander else { return nil }

        switch tableColumn?.identifier {

        case NSUserInterfaceItemIdentifier("Title"):
            let id = NSUserInterfaceItemIdentifier("TitleCell")
            let cell = outlineView.makeView(withIdentifier: id, owner: self) as? NSTableCellView ?? makeTitleCellView(identifier: id)
            cell.textField?.stringValue = commander.title
            cell.textField?.font = commander.isParent
                ? .boldSystemFont(ofSize: NSFont.systemFontSize)
                : .systemFont(ofSize: NSFont.systemFontSize)
            return cell

        case NSUserInterfaceItemIdentifier("Shortcut"):
            guard commander.isLeaf else { return nil }
            let cell = outlineView.makeView(withIdentifier: .init("ShortcutCell"), owner: self) as? ShortcutCellView ?? ShortcutCellView()
            cell.recorderView.delegate = self
            cell.commander = commander
            return cell

        default:
            return nil
        }
    }

    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        return 28
    }

    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        return (item as? Commander)?.isParent ?? false
    }

    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        return (item as? Commander)?.isLeaf ?? false
    }

    // MARK: - Private

    private func makeTitleCellView(identifier: NSUserInterfaceItemIdentifier) -> NSTableCellView {
        let cell = NSTableCellView()
        cell.identifier = identifier
        let textField = NSTextField(labelWithString: "")
        textField.translatesAutoresizingMaskIntoConstraints = false
        cell.textField = textField
        cell.addSubview(textField)
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 2),
            textField.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -2),
            textField.centerYAnchor.constraint(equalTo: cell.centerYAnchor)
        ])
        return cell
    }
}

// MARK: - RecorderViewDelegate

extension ShortcutsViewController: RecorderViewDelegate {

    func recorderViewShouldBeginRecording(_ recorderView: RecorderView) -> Bool {
        return true
    }

    func recorderView(_ recorderView: RecorderView, canRecord commander: Commander) -> Bool {
        return true
    }

    func recorderView(_ recorderView: RecorderView, didChange commander: Commander?) {
        outlineView.reloadData()
        expandAllGroups()
    }

    func recorderViewDidEndRecording(_ recorderView: RecorderView) {
        activeRecorderView = nil
        outlineView.reloadData()
        expandAllGroups()
    }
}

// MARK: - ShortcutCellView

class ShortcutCellView: NSTableCellView {

    let recorderView: RecorderView

    var commander: Commander? {
        didSet { recorderView.commander = commander }
    }

    override init(frame frameRect: NSRect) {
        recorderView = RecorderView(frame: .zero)
        super.init(frame: frameRect)
        identifier = .init("ShortcutCell")
        setupView()
    }

    required init?(coder: NSCoder) {
        recorderView = RecorderView(frame: .zero)
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        recorderView.borderWidth = 1
        recorderView.cornerRadius = 4
        recorderView.clearButtonMode = .whenRecorded
        recorderView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(recorderView)

        NSLayoutConstraint.activate([
            recorderView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            recorderView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            recorderView.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            recorderView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2)
        ])
    }
}

// MARK: - Preview
#if DEBUG
import SwiftUI

private struct NSViewRepresenting<V: NSView>: NSViewRepresentable {
    let make: () -> V
    init(_ make: @escaping () -> V) { self.make = make }
    func makeNSView(context: Context) -> V { make() }
    func updateNSView(_ nsView: V, context: Context) {}
}

#Preview("기본 상태") {
    NSViewRepresenting {
        let view = RecorderView(frame: NSRect(x: 0, y: 0, width: 300, height: 36))
        view.borderWidth = 1
        view.cornerRadius = 6
        return view
    }
    .frame(width: 300, height: 36)
    .padding()
}

#Preview("비활성화") {
    NSViewRepresenting {
        let view = RecorderView(frame: NSRect(x: 0, y: 0, width: 300, height: 36))
        view.borderWidth = 1
        view.cornerRadius = 6
        view.isEnabled = false
        return view
    }
    .frame(width: 300, height: 36)
    .padding()
}
#endif
