import SwiftUI

public extension View {
    func roundedBorder(cornerRadius: CGFloat = 6, lineWidth: CGFloat = 1) -> some View {
        self.overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(.quaternary, lineWidth: lineWidth))
    }

    func roundedBorder<S>(_ content: S, cornerRadius: CGFloat = 6, lineWidth: CGFloat = 1) -> some View where S: ShapeStyle {
        self.overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(content, lineWidth: lineWidth))
    }

    func roundedRectangle<S>(_ content: S, cornerRadius: CGFloat = 6, style: FillStyle = FillStyle()) -> some View where S: ShapeStyle {
        self.overlay(RoundedRectangle(cornerRadius: cornerRadius).fill(content, style: style))
    }
}

public extension View {
    func SoftHDivider(opacity: Double = 0.1) -> some View {
        Color(.gray)
            .opacity(opacity)
            .frame(height: 0.5)
    }

    func SoftVDivider(opacity: Double = 0.1) -> some View {
        Color(.gray)
            .opacity(opacity)
            .frame(width: 0.5)
    }
}
