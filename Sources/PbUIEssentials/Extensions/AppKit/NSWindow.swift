#if os(macOS)

import AppKit

extension NSWindow {
    @inlinable
    public var screenSize: NSSize {
        self.screen?.frame.size ?? (NSScreen.main?.frame.size ?? NSSize(width: 10000, height: 10000))
    }
    
    @inlinable
    public func centerExactly(display: Bool = true, animate: Bool = true) {
        centerExactly(frame.size, display: display, animate: animate)
    }
    
    @inlinable
    public func centerExactly(_ size: NSSize, display: Bool = true, animate: Bool = true) {
        let rect = NSRect(
            x: screenSize.width / 2 - size.width / 2,
            y: screenSize.height / 2 - size.height / 2,
            width: size.width,
            height: size.height
        )
        setFrame(rect, display: display, animate: animate)
    }
}

#endif

