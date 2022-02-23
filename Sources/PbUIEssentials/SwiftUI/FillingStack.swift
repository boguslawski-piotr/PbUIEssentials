/// Swift PbUIEssentials
/// Copyright (c) Piotr Boguslawski
/// MIT license, see License.md file for details.

import SwiftUI

extension View {
    public func FillingHStack<Content: View>(verticalAlignment: VerticalAlignment = .center, horizontalAlignment: HorizontalAlignment = .center, spacing: CGFloat = 0, @ViewBuilder _ content: () -> Content) -> some View {
        VStack(spacing: spacing) {
            if verticalAlignment != .top {
                Spacer()
            }
            HStack(alignment: verticalAlignment, spacing: spacing) {
                if horizontalAlignment != .leading {
                    Spacer()
                }
                content()
                if horizontalAlignment != .trailing {
                    Spacer()
                }
            }
            if verticalAlignment != .bottom {
                Spacer()
            }
        }
    }
    
    public func FillingVStack<Content: View>(horizontalAlignment: HorizontalAlignment = .center, verticalAlignment: VerticalAlignment = .center, spacing: CGFloat = 0, @ViewBuilder _ content: () -> Content) -> some View {
        HStack(spacing: spacing) {
            if horizontalAlignment != .leading {
                Spacer()
            }
            VStack(alignment: horizontalAlignment, spacing: spacing) {
                if verticalAlignment != .top {
                    Spacer()
                }
                content()
                if verticalAlignment != .bottom {
                    Spacer()
                }
            }
            if horizontalAlignment != .trailing {
                Spacer()
            }
        }
    }
}
