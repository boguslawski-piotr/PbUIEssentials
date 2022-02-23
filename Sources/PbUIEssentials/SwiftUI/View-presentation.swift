/// Swift PbUIEssentials
/// Copyright (c) Piotr Boguslawski
/// MIT license, see License.md file for details.

import SwiftUI

public extension View {
    func roundedBorder<S: ShapeStyle>(_ content: S, cornerRadius: CGFloat = 6, lineWidth: CGFloat = 1, style: RoundedCornerStyle = .continuous) -> some View {
        self.overlay(RoundedRectangle(cornerRadius: cornerRadius, style: style).stroke(content, lineWidth: lineWidth))
    }

    func roundedBorder(cornerRadius: CGFloat = 6, lineWidth: CGFloat = 1) -> some View {
        self.roundedBorder(.quaternary, cornerRadius: cornerRadius, lineWidth: lineWidth)
    }

    func roundedRectangle<S: ShapeStyle>(_ content: S, cornerRadius: CGFloat = 6, cornerStyle: RoundedCornerStyle = .continuous, fillStyle: FillStyle = FillStyle()) -> some View {
        self.overlay(RoundedRectangle(cornerRadius: cornerRadius, style: cornerStyle).fill(content, style: fillStyle))
    }

    func roundedRectangle(cornerRadius: CGFloat = 6) -> some View {
        self.roundedRectangle(.ultraThinMaterial, cornerRadius: cornerRadius)
    }
}

public extension View {
    func HDivider(opacity: Double = 0.1) -> some View {
        Color(.gray)
            .opacity(opacity)
            .frame(height: 0.5)
    }

    func VDivider(opacity: Double = 0.1) -> some View {
        Color(.gray)
            .opacity(opacity)
            .frame(width: 0.5)
    }
}
