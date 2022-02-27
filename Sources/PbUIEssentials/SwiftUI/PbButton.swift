/// Swift PbUIEssentials
/// Copyright (c) Piotr Boguslawski
/// MIT license, see License.md file for details.

import SwiftUI

// MARK: Public interface

public enum PbButtonRole {
    case primary, secondary, cancel, destructive
}

public extension View {
    func PbButton<S: StringProtocol>(_ title: S, role: PbButtonRole? = nil, action: @escaping () -> Void) -> some View {
        Button(title, role: ButtonRole(role), action: action)
            .buttonStyle(PbButtonStyleImplementation(role))
    }
    
    func PbButton<S: StringProtocol>(_ title: S, systemImage: String, imageScale: Image.Scale = .medium, role: PbButtonRole? = nil, action: @escaping () -> Void) -> some View {
        Button(role: ButtonRole(role), action: action, label: {
            Label(title, systemImage: systemImage).imageScale(imageScale)
        }).buttonStyle(PbButtonStyleImplementation(role))
    }
    
    func PbImageButton(_ systemImage: String, imageScale: Image.Scale = .large, role: PbButtonRole? = nil, action: @escaping () -> Void) -> some View {
        Button(role: ButtonRole(role), action: action, label: {
            Image(systemName: systemImage).imageScale(imageScale)
        }).buttonStyle(PbButtonStyleImplementation(role, imageButton: true))
    }

    func PbToolbarButton(_ systemImage: String, imageScale: Image.Scale = .large, role: PbButtonRole? = nil, action: @escaping () -> Void) -> some View {
        Button(role: ButtonRole(role), action: action, label: {
            let style = PbButtonStyleImplementation(role, imageButton: true)
            Image(systemName: systemImage)
                .imageScale(imageScale)
                .padding(.horizontal, 1.5) // this is a fix for macOS SwiftUI bug
                .foregroundColor(style.foregroundColor(false))
        })
    }

    func PbToolbarButton<Content: View>(_ systemImage: String, imageScale: Image.Scale = .large, role: PbButtonRole? = nil, @ViewBuilder content: @escaping () -> Content) -> some View {
        SwiftUI.Menu {
            content()
        } label: {
            let style = PbButtonStyleImplementation(role, imageButton: true)
            Image(systemName: systemImage)
                .imageScale(imageScale)
                .padding(.horizontal, 1.5) // this is a fix for macOS SwiftUI bug
                .foregroundColor(style.foregroundColor(false))
        }
        .menuStyle(.borderlessButton)
    }
}

public extension View {
    func PbButtonStyle(role: PbButtonRole? = nil) -> some View {
        self.buttonStyle(PbButtonStyleImplementation(role))
    }
}

// MARK: Implementation

public extension ButtonRole {
    init?(_ role: PbButtonRole?) {
        guard role != nil else { return nil }
        switch role! {
        case .cancel: self = .cancel
        case .destructive: self = .destructive
        default: return nil
        }
    }
}

public struct PbButtonStyleImplementation: ButtonStyle {
    let role: PbButtonRole?
    let imageButton: Bool
    let font: Font
    let minWidth: CGFloat
    let paddingVertical: CGFloat
    let paddingHorizontal: CGFloat

    public init(_ role: PbButtonRole?, imageButton: Bool = false) {
        self.role = role
        self.imageButton = imageButton
        font = role == .primary ? Font.body.bold() : Font.body
        minWidth = imageButton ? 8 : 80
        paddingHorizontal = imageButton ? 0 : 10
        paddingVertical = imageButton ? 0 : role == .primary || role == .cancel ? 5.5 : 5
    }

    public func foregroundColor(_ isPressed: Bool) -> Color {
        var color: Color
        if imageButton && role == .primary {
            color = .accentColor
        } else {
            color =
            role == .destructive
            ? .red
            : role == .cancel
            ? .primary
            : role == .secondary
            ? .secondary
            : role == .primary
            ? .primary
            : .primary
        }
        return color.opacity(isPressed ? 1.0 : 0.75)
    }
    
    public func background(_ isPressed: Bool) -> some ShapeStyle {
        if role == .primary {
            return Color.accentColor.opacity(isPressed ? 1.0 : 0.75)
        } else {
            return Color.secondary.opacity(isPressed ? 0.5 : 0.25)
        }
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(minWidth: minWidth)
            .padding(.vertical, paddingVertical)
            .padding(.horizontal, paddingHorizontal)
            .foregroundColor(foregroundColor(configuration.isPressed))
            .modifier(if: !imageButton, { label in
                label
                    .font(font)
                    .background(background(configuration.isPressed), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
            })
    }
}
