/// Swift PbUIEssentials
/// Copyright (c) Piotr Boguslawski
/// MIT license, see License.md file for details.

#if os(macOS)

import SwiftUI
import PbEssentials

open class PbViewController: NSViewController, PbObservableObject {
    // MARK: Public interface
    
    open var window: NSWindow? { view.window }
    
    open override var title: String? {
        get { super.title }
        set {
            objectWillChange.send()
            super.title = newValue
        }
    }

    public init<V: View>(_ view: V) {
        super.init(nibName: nil, bundle: nil)
        self.view = NSHostingView(rootView: view.environmentObject(self))
    }

    public convenience init<V: View>(@ViewBuilder view: () -> V) {
        self.init(view())
    }

    // MARK: Very unimportant code ;)
    
    public required init?(coder: NSCoder) {
        fatalError("NSSwiftUIViewController.init(coder:) has not been implemented.")
    }
}

#endif
