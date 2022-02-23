/// Swift PbUIEssentials
/// Copyright (c) Piotr Boguslawski
/// MIT license, see License.md file for details.

import SwiftUI

public enum TextFieldRole {
    case primary, secondary
}

public extension View {
    func PbTextFieldStyle(role: TextFieldRole = .primary) -> some View {
        self
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .roundedBorder(role == .primary ? .tertiary : .quaternary)
            .textFieldStyle(.plain)
    }

    func PbTitleTextFieldStyle(role: TextFieldRole = .primary) -> some View {
        self
            .PbTextFieldStyle(role: role)
            .font(.title3)
    }
}

public extension View {
    func PbTextEditorStyle(role: TextFieldRole = .primary) -> some View {
        self
            .font(.body)
            .padding(.horizontal, 5)
            .padding(.vertical, 10)
            .background(.clear)
            .roundedBorder(role == .primary ? .tertiary : .quaternary)
    }
}

#if os(macOS)

import AppKit

/// Removes background from TextEditor.
extension NSTextView {
    open override var frame: CGRect {
        didSet {
            backgroundColor = .clear
            drawsBackground = true
        }
        
    }
}

#endif
