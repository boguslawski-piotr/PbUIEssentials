import SwiftUI

#if os(macOS)

public class SwiftUIViewController: NSViewController, ObservableObject {
    @Published public var viewBounds: NSRect = NSRect.zero
    @Published public var viewFrame: NSRect = NSRect.zero

    public lazy var window: NSWindow? = view.window

    public override var title: String? {
        get { super.title }
        set {
            objectWillChange.send()
            super.title = newValue
        }
    }

    public init<Content: View>(_ content: Content) {
        super.init(nibName: nil, bundle: nil)
        view = NSHostingView(rootView: content.environmentObject(self))
    }

    public init<Content: View>(@ViewBuilder content: () -> Content) {
        super.init(nibName: nil, bundle: nil)
        view = NSHostingView(rootView: content().environmentObject(self))
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func viewWillLayout() {
        if view.bounds != viewBounds {
            viewBounds = view.bounds
        }
        if view.frame != viewFrame {
            viewFrame = view.frame
        }
    }
}

#endif
