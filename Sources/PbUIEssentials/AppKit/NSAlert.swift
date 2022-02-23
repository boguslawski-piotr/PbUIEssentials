/// Swift PbUIEssentials
/// Copyright (c) Piotr Boguslawski
/// MIT license, see License.md file for details.

#if os(macOS)

import AppKit

extension NSAlert {
    public static func information(_ title: String, message: String = "", button: PbAlert.Button? = nil, style: NSAlert.Style = .informational) {
        _ = confirmation(title, message: message, buttons: [button ?? .init("OK", .primary)], style: style)
    }

    public static func confirmation(_ title: String, message: String = "", buttons: [PbAlert.Button]? = nil, style: NSAlert.Style = .informational) -> NSApplication.ModalResponse
    {
        let confirmation = NSAlert()
        confirmation.messageText = title
        confirmation.informativeText = message
        confirmation.alertStyle = style
        
        let buttons = buttons == nil || buttons!.isEmpty ? [.init(Bundle.main.L("Yes")), .init(Bundle.main.L("No"))] : buttons!
        buttons.forEach { button in
            confirmation.addButton(withTitle: button.title).hasDestructiveAction = button.role == .destructive
        }

        return confirmation.runModal()
    }
}

#endif

