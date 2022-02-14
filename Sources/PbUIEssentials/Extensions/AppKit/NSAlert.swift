#if os(macOS)

import AppKit

extension NSAlert {
    public static func present(_ title: String, message: String = "", style: NSAlert.Style = .informational) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = title
            alert.informativeText = message
            alert.alertStyle = style
            alert.runModal()
        }
    }
}

#endif

