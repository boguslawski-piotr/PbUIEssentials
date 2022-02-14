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

#if !os(macOS)

public struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void
    public func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

public extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}

#endif
