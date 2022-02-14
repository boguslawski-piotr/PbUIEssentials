#if os(macOS)

import AppKit

extension NSWindow {
    @inlinable
    public var screenSize: NSSize {
        self.screen?.visibleFrame.size ?? (NSScreen.main?.visibleFrame.size ?? NSSize(width: 10000, height: 10000))
    }
}

#endif

