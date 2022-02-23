/// Swift PbUIEssentials
/// Copyright (c) Piotr Boguslawski
/// MIT license, see License.md file for details.

import SwiftUI

public extension View {
    @ViewBuilder
    func navigationViewStyle(stacked: Bool) -> some View {
#if !os(macOS)
        if stacked {
            self.navigationViewStyle(.stack)
        } else {
            self.navigationViewStyle(.columns)
        }
#else
        self
#endif
    }
}
