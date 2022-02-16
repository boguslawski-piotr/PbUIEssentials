#if os(macOS)

import AppKit
import PbEssentials

/// Removes background from TextEditor.
extension NSTextView {
    open override var frame: CGRect {
        didSet {
            backgroundColor = .clear
            drawsBackground = true
        }
        
    }
}

/// Removes background from List.
extension NSTableView {
    open override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        backgroundColor = NSColor.clear
        if let esv = enclosingScrollView {
            esv.drawsBackground = false
        }
    }
}

extension NSOpenPanel {
    private class OpenPanelDelegate: NSObject, NSOpenSavePanelDelegate {
        func panel(_ sender: Any, shouldEnable url: URL) -> Bool {
            return true
        }
    }
    
    private static var openPanelDelegate = OpenPanelDelegate()
    
    public static func selectDirectory(_ title: String, showsHiddenFiles: Bool = true) -> URL? {
        let openPanel = NSOpenPanel()
        
        openPanel.title = title
        openPanel.canChooseFiles = false
        openPanel.canCreateDirectories = true
        openPanel.canChooseDirectories = true
        openPanel.showsHiddenFiles = showsHiddenFiles
        openPanel.allowsMultipleSelection = false
        openPanel.delegate = openPanelDelegate
        
        let result = openPanel.runModal()
        return result == .OK ? openPanel.url : nil
    }
}

#endif

