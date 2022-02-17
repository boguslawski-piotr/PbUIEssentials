import SwiftUI

public extension View {
    func roundedBorder<S>(_ content: S, cornerRadius: CGFloat = 6, lineWidth: CGFloat = 1, style: RoundedCornerStyle = .continuous) -> some View where S: ShapeStyle {
        self.overlay(RoundedRectangle(cornerRadius: cornerRadius, style: style).stroke(content, lineWidth: lineWidth))
    }

    func roundedRectangle<S>(_ content: S, cornerRadius: CGFloat = 6, cornerStyle: RoundedCornerStyle = .continuous, fillStyle: FillStyle = FillStyle()) -> some View where S: ShapeStyle {
        self.overlay(RoundedRectangle(cornerRadius: cornerRadius, style: cornerStyle).fill(content, style: fillStyle))
    }
}

public extension View {
    func roundedBorder(cornerRadius: CGFloat = 6, lineWidth: CGFloat = 1, style: RoundedCornerStyle = .continuous) -> some View {
        self.roundedBorder(.quaternary, cornerRadius: cornerRadius, lineWidth: lineWidth, style: style)
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
