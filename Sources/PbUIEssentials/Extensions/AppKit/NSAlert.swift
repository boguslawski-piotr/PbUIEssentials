#if os(macOS)

import AppKit

extension NSAlert {
    public static func information(_ title: String, message: String = "", button1Title: String = "", style: NSAlert.Style = .informational) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = style
        if !button1Title.isEmpty {
            alert.addButton(withTitle: button1Title)
        }
        alert.runModal()
    }

    public enum ConfirmationResult {
        case button1, button2, button3, undefined
    }
    
    public static func confirmation(
        _ title: String,
        message: String = "",
        button1Title: String,
        button1HasDestructiveAction: Bool = false,
        button2Title: String,
        button2HasDestructiveAction: Bool = false,
        button3Title: String = "",
        button3HasDestructiveAction: Bool = false,
        style: NSAlert.Style = .informational
    ) -> ConfirmationResult
    {
        let confirmation = NSAlert()
        confirmation.messageText = title
        confirmation.informativeText = message
        confirmation.alertStyle = style
        
        confirmation.addButton(withTitle: button1Title).hasDestructiveAction = button1HasDestructiveAction
        confirmation.addButton(withTitle: button2Title).hasDestructiveAction = button2HasDestructiveAction
        if !button3Title.isEmpty {
            confirmation.addButton(withTitle: button3Title).hasDestructiveAction = button3HasDestructiveAction
        }
        
        let result = confirmation.runModal()
        
        switch result {
        case NSApplication.ModalResponse.alertFirstButtonReturn:
            return .button1
        case NSApplication.ModalResponse.alertSecondButtonReturn:
            return .button2
        case NSApplication.ModalResponse.alertThirdButtonReturn:
            return .button3
        default:
            return .undefined
        }
    }
}

#endif

