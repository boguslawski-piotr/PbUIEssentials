/// Swift PbUIEssentials
/// Copyright (c) Piotr Boguslawski
/// MIT license, see License.md file for details.

#if os(macOS)

import SwiftUI
import PbEssentials
import PbRepository

@MainActor
open class PbWindowController: NSObject, NSWindowDelegate, PbObservableObject {
    // MARK: Definitions
    
    public enum Status: Codable {
        case notVisible, modal, modalSheet, presented(asSheet: Bool)
    }
    
    public typealias Style = NSWindow.StyleMask

    public enum Position: Codable {
        case systemDecides, screenCenter, bottomLeft(CGPoint), topLeft(CGPoint), keyWindowCenter
    }
    
    public struct State: Codable, Equatable {
        var frame: String = NSStringFromRect(NSZeroRect)
        var isVisible: Bool = false
        var isKey: Bool = false
        var isMiniaturized: Bool = false
        var isZoomed: Bool = false
    }

    @PbPublished(.withLock) open var status: Status = .notVisible
    @PbStored("") open var state: State = State()
    
    open var viewController: PbSplitViewController?
    open var viewWindow: NSWindow?

    open var views: [AnyView]!
    open var title: String!
    open var style: Style!
    open var name: String?
    
    // MARK: Initialization
    
    public init(title: String? = nil, style: Style? = nil, name: String? = nil, _ views: [AnyView]) {
        super.init()
        self.views = views
        self.title = title ?? Bundle.main.displayName
        self.style = style ?? defaultStyle()
        self.name = name?.asPathComponent()
        if self.name != nil {
            self.name! += ".\(self.classForCoder)"
            _state.name = self.name!
        }
    }

    public convenience init<V: View>(title: String? = nil, style: Style? = nil, name: String? = nil, _ view: V) {
        self.init(title: title, style: style, name: name, [AnyView(view)])
    }
    
    public convenience init<V: View>(title: String? = nil, style: Style? = nil, name: String? = nil, @ViewBuilder _ view: @escaping () -> V) {
        self.init(title: title, style: style, name: name, [AnyView(view())])
    }
    
    open func defaultStyle() -> Style {
        [.titled, .fullSizeContentView]
    }
    
    open func makeViewController() {
        guard viewController == nil else { return }
        viewController = PbSplitViewController(name: name, views.map { AnyView($0.environmentObject(self)) })
    }
    
    open func makeViewWindow() {
        guard viewWindow == nil else { return }
        makeViewController()
        viewWindow = NSWindow(contentViewController: viewController!)
        viewWindow!.styleMask = self.style
        viewWindow!.title = self.title
        viewWindow!.identifier = name != nil ? .init(name!) : nil
        viewWindow!.delegate = self
    }
    
    var windowWithSheet: NSWindow?

    func makeWindowForSheet() {
        guard windowWithSheet == nil else { return }
        windowWithSheet = NSWindow(contentRect: .zero, styleMask: [.borderless], backing: .buffered, defer: true)
        windowWithSheet!.isReleasedWhenClosed = false
        windowWithSheet!.delegate = self
    }
    
    // MARK: Modal presentation
    
    @discardableResult
    open func runModal(asSheet: Bool = true, position: Position = .screenCenter) -> NSApplication.ModalResponse {
        guard case .notVisible = status else { dbg("Unable to execute runModal while the window is already on the screen."); return .abort }
        
        var result: NSApplication.ModalResponse = .cancel
        makeViewWindow()
        status = .modal
        
        if asSheet {
            makeWindowForSheet()
            setPosition(position, for: windowWithSheet!, displayed: self.viewWindow!)
            windowWithSheet!.makeKeyAndOrderFront(self)
            DispatchQueue.main.async { [weak self] in
                if let self = self {
                    self.windowWithSheet!.beginSheet(self.viewWindow!, completionHandler: { _ in })
                }
            }
            result = NSApp.runModal(for: windowWithSheet!)
            windowWithSheet!.endSheet(viewWindow!)
            viewWindow?.close()
            windowWithSheet?.close()
        }
        else {
            adjustViewWindowStyle(modal: true)
            if !restoreState() {
                setPosition(position, for: viewWindow!)
            }
            viewWindow!.orderFront(self)
            result = NSApp.runModal(for: self.viewWindow!)
            viewWindow?.close()
        }

        status = .notVisible
        return result
    }
    
    weak var externalWindowWithSheet: NSWindow?

    @discardableResult
    open func runModalSheet(for window: NSWindow, critical: Bool = false) async -> NSApplication.ModalResponse {
        guard case .notVisible = status else { dbg("Unable to execute runModalSheet while the window is already on the screen."); return .abort }

        makeViewWindow()
        status = .modalSheet
        externalWindowWithSheet = window
        let result = critical ? await window.beginCriticalSheet(self.viewWindow!) : await window.beginSheet(self.viewWindow!)
        externalWindowWithSheet = nil
        status = .notVisible
        return result
    }

    open func runModalSheet(for window: NSWindow, critical: Bool = false, completion handler: ((NSApplication.ModalResponse) -> Void)? = nil) {
        guard case .notVisible = status else { dbg("Unable to execute runModalSheet while the window is already on the screen."); handler?(.abort); return }

        makeViewWindow()
        status = .modalSheet
        externalWindowWithSheet = window
        
        let _handler = { [weak self] (result: NSApplication.ModalResponse) in
            self?.externalWindowWithSheet = nil
            self?.status = .notVisible
            handler?(result)
        }
        
        if critical {
            window.beginCriticalSheet(viewWindow!, completionHandler: _handler)
        } else {
            window.beginSheet(viewWindow!, completionHandler: _handler)
        }
    }

    open func endModal(_ result: NSApplication.ModalResponse) {
        if case .modalSheet = status, externalWindowWithSheet != nil {
            externalWindowWithSheet!.endSheet(viewWindow!, returnCode: result)
        }
        if case .modal = status {
            NSApp.stopModal(withCode: result)
        }
    }
    
    // MARK: Non modal presentation
    
    @PbWithLock var shouldPresent = false

    open func present(asSheet: Bool = true, position: Position = .systemDecides, delayedBy ti: TimeInterval = 0) {
        shouldPresent = true
        DispatchQueue.main.asyncAfter(deadline: .now() + ti) { [weak self] in
            guard let self = self else { return }
            guard self.shouldPresent else { return }
            switch self.status {
            case .notVisible:
                break
            case .modal:
                return
            case .modalSheet:
                return
            case .presented(asSheet: let asSheet):
                if asSheet {
                    self.windowWithSheet?.makeKeyAndOrderFront(self)
                } else  {
                    self.viewWindow?.makeKeyAndOrderFront(self)
                }
                return
            }
            
            self.makeViewWindow()
            if asSheet {
                self.status = .presented(asSheet: true)
                self.makeWindowForSheet()
                self.setPosition(position, for: self.windowWithSheet!, displayed: self.viewWindow!)
                self.windowWithSheet!.makeKeyAndOrderFront(self)
                self.windowWithSheet!.beginSheet(self.viewWindow!, completionHandler: { _ in })
            } else {
                self.status = .presented(asSheet: false)
                self.adjustViewWindowStyle(modal: false)
                if !self.restoreState() {
                    self.setPosition(position, for: self.viewWindow!)
                }
                self.viewWindow?.makeKeyAndOrderFront(self)
            }
        }
    }
    
    open func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow, window === viewWindow {
            dbg("will close", window.identifier as Any, status)
            status = .notVisible
        }
    }
    
    open func close() {
        shouldPresent = false
        if case .presented(let asSheet) = status, viewWindow != nil {
            if asSheet {
                windowWithSheet?.endSheet(viewWindow!)
                viewWindow!.close()
                windowWithSheet?.close()
            } else {
                viewWindow!.close()
            }
            status = .notVisible
        }
    }
    
    // MARK: Deinitialization
    
    open func release() {
        DispatchQueue.main.async { [weak self] in
            self?.viewController = nil
            self?.viewWindow = nil
            self?.windowWithSheet = nil
        }
    }
    
    deinit {
        dbg("deinit")
    }
    
    // MARK: Utilities
    
    open func windowDidMove(_ notification: Notification) {
        saveState()
    }
    
    open func saveState() {
        guard viewWindow != nil else { return }
        
        let newState = State(
            frame: NSStringFromRect(viewWindow!.frame), // frame: NSStringFromRect(notZoomedFrame),
            isVisible: viewWindow!.isVisible,
            isKey: viewWindow!.isKeyWindow,
            isMiniaturized: viewWindow!.isMiniaturized,
            isZoomed: viewWindow!.isZoomed
        )
        if newState != state {
            state = newState
        }
    }

    open func restoreState() -> Bool {
        if viewWindow != nil {
            let frame = NSRectFromString(state.frame)
            if !frame.isEmpty {
                viewWindow!.setFrame(frame, display: false)
                return true
            }
        }
        return false
    }
    
    open func setPosition(_ position: Position, for window: NSWindow, displayed sheetWindow: NSWindow? = nil) {
        switch position {
        case .systemDecides:
            if sheetWindow != nil {
                // System ;) decides that sheet windows should be centered on screen.
                window.center()
            }
            break

        case .screenCenter:
            window.center()
            if sheetWindow != nil {
                // A little correction is needed in order to get more or less
                // similar window position as we have when sheet is not used.
                var origin = window.frame.origin
                origin.y += sheetWindow!.frame.height / 4
                window.setFrameOrigin(origin)
            }

        case .bottomLeft(let bottomLeft):
            window.setFrameOrigin(bottomLeft)

        case .topLeft(let topLeft):
            window.setFrameTopLeftPoint(topLeft)

        case .keyWindowCenter:
            if let keyWindowFrame = NSApp.keyWindow?.frame {
                let x = (keyWindowFrame.width / 2 + keyWindowFrame.minX) - window.frame.width / 2
                var y: CGFloat
                if sheetWindow == nil {
                    y = (keyWindowFrame.height / 2 + keyWindowFrame.minY) - window.frame.height / 2
                } else {
                    y = keyWindowFrame.minY + sheetWindow!.frame.height + (keyWindowFrame.height - sheetWindow!.frame.height) / 2
                }
                window.setFrameOrigin(NSPoint(x: x, y: y))
            } else {
                window.center()
            }
        }
    }
    
    open func adjustViewWindowStyle(modal: Bool) {
        viewWindow?.styleMask = style
        if modal {
            viewWindow?.styleMask.remove([.closable])
        }
    }
}

#endif
