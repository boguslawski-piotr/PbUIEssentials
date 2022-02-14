import SwiftUI

extension EdgeInsets {
    public var vertical: CGFloat { self.bottom + self.top }
    public var horizontal: CGFloat { self.trailing + self.leading }
}
