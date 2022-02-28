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
    
    public enum Status: Codable, Equatable {
        case notVisible, modal, modalSheet, presented(asSheet: Bool)
    }
    
    public typealias Style = NSWindow.StyleMask

    public enum Position: Codable {
        case systemDecides, screenCenter, bottomLeft(CGPoint), topLeft(CGPoint), keyWindowCenter
    }
    
    public struct State: Codable, Equatable {
        public var status: Status = .notVisible
        public var frame: String = NSStringFromRect(NSZeroRect)
        public var isVisible: Bool = false
        public var isKey: Bool = false
        public var isMiniaturized: Bool = false
        public var isZoomed: Bool = false
    }

    public class ViewWindow: NSWindow {
        public var notZoomedFrame: NSRect = .zero
    }
    
    @PbPublished(.withLock) open var status: Status = .notVisible
    @PbStored("") open var state: State = State()
    
    open var viewController: PbSplitViewController?
    open var viewWindow: ViewWindow?

    open var views: [AnyView]!
    open var style: Style!

    @PbPublished open var title: String = "" {
        didSet {
            viewWindow?.title = title
        }
    }

    @PbPublished open var name: String = "" {
        didSet {
            nameDidSet()
        }
    }

    open func nameDidSet() {
        if !name.isEmpty {
            _state.name = name + ".\(self.classForCoder)"
            viewController?.name = name
            saveState()
        }
    }

    // MARK: Initialization
    
    public init(title: String? = nil, style: Style? = nil, name: String? = nil, _ views: [AnyView]) {
        super.init()
        self.views = views
        self.title = title ?? Bundle.main.displayName
        self.style = style ?? defaultStyle()
        self.name = name?.asPathComponent() ?? ""
        nameDidSet()
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
        viewWindow = ViewWindow(contentViewController: viewController!)
        viewWindow!.styleMask = self.style
        viewWindow!.title = self.title
        viewWindow!.identifier = !name.isEmpty ? .init(name) : nil
        viewWindow!.delegate = self
    }
    
    var windowWithSheet: NSWindow?

    func makeWindowForSheet() {
        guard windowWithSheet == nil else { return }
        windowWithSheet = NSWindow(contentRect: .zero, styleMask: [.borderless], backing: .buffered, defer: true)
        windowWithSheet!.isReleasedWhenClosed = false
    }
    
    // MARK: Modal presentation
    
    @discardableResult
    open func runModal(asSheet: Bool = true, position: Position = .screenCenter) -> NSApplication.ModalResponse {
        guard case .notVisible = status else { return .abort }
        
        var result: NSApplication.ModalResponse = .cancel
        makeViewWindow()
        status = .modal
        
        if asSheet {
            makeWindowForSheet()
            setPosition(position, for: windowWithSheet!, displaying: self.viewWindow!)
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
            if !restoreViewWindowPositionAndSize() {
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
        guard case .notVisible = status else { return .abort }

        makeViewWindow()
        status = .modalSheet
        externalWindowWithSheet = window
        let result = critical ? await window.beginCriticalSheet(self.viewWindow!) : await window.beginSheet(self.viewWindow!)
        externalWindowWithSheet = nil
        status = .notVisible
        return result
    }

    open func runModalSheet(for window: NSWindow, critical: Bool = false, completion handler: ((NSApplication.ModalResponse) -> Void)? = nil) {
        guard case .notVisible = status else { handler?(.abort); return }

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

    open func present(asSheet: Bool = true, position: Position = .systemDecides, delayedBy ti: TimeInterval = 0, completion handler: ((Bool) -> Void)? = nil) {
        shouldPresent = true
        DispatchQueue.main.asyncAfter(deadline: .now() + ti) { [weak self] in
            guard let self = self else { handler?(false); return }
            guard self.shouldPresent else { handler?(false); return }
            
            if !self.makeKey() {
                self.makeViewWindow()
                if asSheet {
                    self.status = .presented(asSheet: true)
                    self.makeWindowForSheet()
                    self.setPosition(position, for: self.windowWithSheet!, displaying: self.viewWindow!)
                    self.windowWithSheet!.makeKeyAndOrderFront(self)
                    self.windowWithSheet!.beginSheet(self.viewWindow!, completionHandler: { _ in })
                } else {
                    self.status = .presented(asSheet: false)
                    self.adjustViewWindowStyle(modal: false)
                    if !self.restoreViewWindowPositionAndSize() {
                        self.setPosition(position, for: self.viewWindow!)
                    }
                    self.viewWindow?.makeKeyAndOrderFront(self)
                }
            }
            handler?(true)
        }
    }
    
    @discardableResult
    open func restore(delayedBy ti: TimeInterval = 0, completion handler: ((Bool) -> Void)? = nil) -> Bool {
        switch state.status {
        case .presented(asSheet: false):
            fallthrough
        case .notVisible:
            shouldPresent = true
            DispatchQueue.main.asyncAfter(deadline: .now() + ti) { [weak self] in
                guard let self = self else { handler?(false); return }
                guard self.shouldPresent else { handler?(false); return }
                
                self.makeViewWindow()
                self.status = .presented(asSheet: false)
                self.adjustViewWindowStyle(modal: false)
                self.restoreViewWindowPositionAndSize()
                if self.state.isMiniaturized {
                    self.viewWindow!.orderBack(self)
                    self.viewWindow!.miniaturize(self)
                } else {
                    if self.state.isVisible {
                        if self.state.isKey {
                            self.viewWindow!.makeKeyAndOrderFront(self)
                        } else {
                            self.viewWindow!.orderFront(self)
                        }
                    }
                }
                handler?(true)
            }
            return true
            
        default:
            return false
        }
    }
    
    @discardableResult
    open func makeKey(orderFront: Bool = true) -> Bool {
        guard viewWindow != nil else { return false }
        switch self.status {
        case .notVisible:
            return false
        default:
            if orderFront {
                viewWindow?.makeKeyAndOrderFront(self)
            } else {
                viewWindow?.makeKey()
            }
            return true
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
    
    @PbWithLock var releaseInProgress = false
    
    open func closeAndRelease() {
        releaseInProgress = true
        DispatchQueue.main.async { [weak self] in
            self?.endModal(.abort)
            self?.close()
            self?.status = .notVisible
            self?.viewController = nil
            self?.viewWindow = nil
            self?.windowWithSheet = nil
        }
    }
    
    // MARK: Utilities & window delegate
    
    open var isVisible: Bool {
        if case .notVisible = status { return false }
        return viewWindow?.isVisible ?? false
    }
    
    open func windowDidBecomeMain(_ notification: Notification) {
        saveState()
    }
    
    open func windowDidResignMain(_ notification: Notification) {
        if !releaseInProgress {
            saveState()
        }
    }

    open func windowDidBecomeKey(_ notification: Notification) {
        saveState()
    }
    
    open func windowDidResignKey(_ notification: Notification) {
        if !releaseInProgress {
            saveState()
        }
    }
    
    open func windowDidMiniaturize(_ notification: Notification) {
        saveState()
    }
    
    open func windowDidDeminiaturize(_ notification: Notification) {
        saveState()
    }
    
    open func windowDidMove(_ notification: Notification) {
        windowdidMoveOrResize()
    }
    
    open func windowDidEndLiveResize(_ notification: Notification) {
        windowdidMoveOrResize()
    }
    
    open func windowdidMoveOrResize() {
        guard viewWindow != nil else { return }
        if !viewWindow!.isZoomed || !style.contains(.resizable) {
            viewWindow!.notZoomedFrame = viewWindow!.frame
        }
        saveState()
    }

    open func windowWillClose(_ notification: Notification) {
        if !releaseInProgress {
            // Saving state should be delayed because isVisible flag is
            // still true here and there is no windowDidClose event :(
            DispatchQueue.main.async {
                self.saveState()
            }
            status = .notVisible
        }
    }
    
    open func saveState() {
        guard viewWindow != nil else { return }
        state = State(
            status: status,
            frame: NSStringFromRect(viewWindow!.notZoomedFrame),
            isVisible: viewWindow!.isVisible,
            isKey: viewWindow!.isKeyWindow,
            isMiniaturized: viewWindow!.isMiniaturized,
            isZoomed: viewWindow!.isZoomed
        )
    }
    
    open func setPosition(_ position: Position, for window: NSWindow, displaying sheetWindow: NSWindow? = nil) {
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
    
    @discardableResult
    open func restoreViewWindowPositionAndSize() -> Bool {
        guard viewWindow != nil else { return false }
        let frame = NSRectFromString(state.frame)
        guard !frame.isEmpty else { return false }

        let state = self.state
        if style.contains(.resizable) {
            viewWindow!.setFrame(frame, display: false)
        } else {
            viewWindow!.setFrameTopLeftPoint(NSPoint(x: frame.minX, y: frame.maxY))
        }

        viewWindow!.notZoomedFrame = frame
        if state.isZoomed && style.contains(.resizable) {
            viewWindow!.zoom(self)
        }
        return true
    }
    
    open func adjustViewWindowStyle(modal: Bool) {
        viewWindow?.styleMask = style
        if modal {
            viewWindow?.styleMask.remove([.closable])
        }
    }
}

#endif
