/// Swift PbUIEssentials
/// Copyright (c) Piotr Boguslawski
/// MIT license, see License.md file for details.

#if os(macOS)

import SwiftUI
import PbEssentials

open class PbWindowController: NSObject, NSWindowDelegate, PbObservableObject {
    // MARK: Public interface
    
    public enum Position {
        case screenCenter, keyWindowCenter
    }
    
    open var viewController: PbViewController?
    open var viewWindow: NSWindow?

    public init<V: View>(title: String? = nil, styleMask style: NSWindow.StyleMask? = nil, _ view: V) {
        super.init()
        
        viewController = PbViewController(view.environmentObject(self))
        viewWindow = NSWindow(contentViewController: viewController!)
        viewWindow!.styleMask = style ?? [.titled, .fullSizeContentView]
        viewWindow!.title = title ?? Bundle.main.displayName
        viewWindow!.delegate = self
    }

    public convenience init<V: View>(title: String? = nil, styleMask style: NSWindow.StyleMask? = nil, @ViewBuilder _ view: @escaping () -> V) {
        self.init(title: title, styleMask: style, view())
    }
    
    @discardableResult
    open func runModal(asSheet: Bool = true, position: Position = .screenCenter) -> NSApplication.ModalResponse {
        var result: NSApplication.ModalResponse = .cancel
        if asSheet {
            makeWindowForSheet()
            setPosition(position, for: windowWithSheet!)
            windowWithSheet!.makeKeyAndOrderFront(self)
            DispatchQueue.main.async { [weak self] in
                if let self = self {
                    self.windowWithSheet!.beginSheet(self.viewWindow!, completionHandler: { _ in })
                }
            }
            modalWindow = windowWithSheet!
            result = NSApp.runModal(for: windowWithSheet!)
            windowWithSheet!.endSheet(viewWindow!)
            windowWithSheet!.close()
        }
        else {
            setPosition(position, for: viewWindow!)
            viewWindow!.orderFront(self)
            modalWindow = self.viewWindow!
            result = NSApp.runModal(for: self.viewWindow!)
            viewWindow?.close()
        }

        modalWindow = nil
        return result
    }
    
    @discardableResult
    open func runModalSheet(for window: NSWindow) async -> NSApplication.ModalResponse {
        externalWindowWithSheet = window
        let result = await window.beginSheet(self.viewWindow!)
        externalWindowWithSheet = nil
        return result
    }

    open func runModalSheet(for window: NSWindow, completion handler: ((NSApplication.ModalResponse) -> Void)? = nil) {
        externalWindowWithSheet = window
        window.beginSheet(self.viewWindow!) { [weak self] result in
            self?.externalWindowWithSheet = nil
            handler?(result)
        }
    }

    open func endModal(_ result: NSApplication.ModalResponse) {
        if externalWindowWithSheet != nil {
            externalWindowWithSheet!.endSheet(viewWindow!, returnCode: result)
        }
        if modalWindow != nil {
            NSApp.stopModal(withCode: result)
        }
    }
    
    open func present(asSheet: Bool = true, position: Position = .screenCenter, delayedBy ti: TimeInterval = 0) {
        shouldPresent = true
        DispatchQueue.main.asyncAfter(deadline: .now() + ti) { [weak self] in
            if let self = self {
                guard self.shouldPresent else { return }
                if asSheet {
                    guard !(self.windowWithSheet?.isVisible ?? false) else { return }
                    self.makeWindowForSheet()
                    self.setPosition(position, for: self.windowWithSheet!)
                    self.windowWithSheet!.makeKeyAndOrderFront(self)
                    self.windowWithSheet!.beginSheet(self.viewWindow!, completionHandler: { _ in })
                    self.presentedAsSheet = true
                } else {
                    self.setPosition(position, for: self.viewWindow!)
                    self.viewWindow?.makeKeyAndOrderFront(self)
                    self.presentedAsSheet = false
                }
            }
        }
    }
    
    open func close() {
        shouldPresent = false
        if presentedAsSheet {
            guard (windowWithSheet?.isVisible ?? false) else { return }
            windowWithSheet?.endSheet(viewWindow!)
            windowWithSheet?.close()
        } else {
            viewWindow?.close()
        }
    }
    
    open func release() {
        DispatchQueue.main.async { [weak self] in
            self?.viewController = nil
            self?.viewWindow = nil
            self?.windowWithSheet = nil
        }
    }
    
    deinit {
        dbg("deinit...")
    }
    
    // MARK: Window delegate
    
    open func windowWillBeginSheet(_ notification: Notification) {
//        dbg("will begin sheet")
    }
    
    open func windowDidEndSheet(_ notification: Notification) {
//        dbg("did end sheet")
    }
    
    open func windowShouldClose(_ sender: NSWindow) -> Bool {
        dbg("window should close", sender.description)
        return true
    }
    
    open func windowWillClose(_ notification: Notification) {
//        if let window = notification.object as? NSWindow {
//            dbg("windowWithSheet will close", window.contentViewController as Any)
//        }
    }
    
    open func windowShouldZoom(_ window: NSWindow, toFrame newFrame: NSRect) -> Bool {
        return false
    }
    
    // MARK: Private implementation
    
    weak var externalWindowWithSheet: NSWindow?
    weak var modalWindow: NSWindow?

    var windowWithSheet: NSWindow?

    @PbWithLock var shouldPresent = false
    @PbWithLock var presentedAsSheet = false
    
    func makeWindowForSheet() {
        if windowWithSheet == nil {
            windowWithSheet = NSWindow(contentRect: .zero, styleMask: [.borderless], backing: .buffered, defer: true)
            windowWithSheet!.isReleasedWhenClosed = false
            windowWithSheet!.delegate = self
        }
    }
    
    func setPosition(_ position: Position, for window: NSWindow) {
        switch position {
        case .screenCenter:
            window.center()
        case .keyWindowCenter:
            if let frame = NSApp.keyWindow?.frame {
                let x = (frame.width / 2 + frame.minX) - window.frame.width / 2
                let y = (frame.height / 4 * 3 + frame.minY) - window.frame.height
                window.setFrameOrigin(NSPoint(x: x, y: y))
            } else {
                window.center()
            }
        }
    }
}

#endif
