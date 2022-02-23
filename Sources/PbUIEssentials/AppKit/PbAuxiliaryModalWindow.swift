/// Swift PbUIEssentials
/// Copyright (c) Piotr Boguslawski
/// MIT license, see License.md file for details.

#if os(macOS)

import SwiftUI
import PbEssentials

open class PbAuxiliaryModalWindow: PbObservableObject {
    // MARK: ...?

    open var releaseWhenClosed = true
    
    open func autoRelease() {
        if releaseWhenClosed {
            windowController.release()
        }
    }
    
    var _windowController: PbWindowController?
    open var windowController: PbWindowController {
        _windowController = _windowController == nil ? makeWindowController() : _windowController
        return _windowController!
    }
    
    open func makeWindowController() -> PbWindowController {
        preconditionFailure("You should always create a subclass of PbAuxiliaryWindow.")
    }
    
    @discardableResult
    open func runModal(asSheet: Bool = true, position: PbWindowController.Position = .screenCenter) -> NSApplication.ModalResponse {
        let result = windowController.runModal(asSheet: asSheet, position: position)
        autoRelease()
        return result
    }
    
    @discardableResult
    open func runModalSheet(for window: NSWindow) async -> NSApplication.ModalResponse {
        let result = await windowController.runModalSheet(for: window)
        autoRelease()
        return result
    }
    
    open func runModalSheet(for window: NSWindow, completion handler: ((NSApplication.ModalResponse) -> Void)? = nil) {
        windowController.runModalSheet(for: window) { [weak self] result in
            self?.autoRelease()
            handler?(result)
        }
    }
    
    // MARK: Image
    
    public static let systemImageForError = "exclamationmark.triangle"
    public static var defaultImage: Image? = nil
    public static var defaultImageSize = CGSize(width: 85, height: 85)
    public static var defaultImageColor: Color = .accentColor

    open var image: Image
    open var imageSize = defaultImageSize
    open var imageColor = defaultImageColor
    
    public init(_ image: Image? = nil) {
        if image == nil {
            if PbAuxiliaryModalWindow.defaultImage == nil {
                let image = Bundle.main.image(forResource: "AppIcon")
                self.image = image != nil ? Image(nsImage: image!) : Image(systemName: PbAuxiliaryModalWindow.systemImageForError)
            } else {
                self.image = PbAuxiliaryModalWindow.defaultImage!
            }
        } else {
            self.image = image!
        }
    }
    
    // In the next two methods we need to use AnyView instead of "some View"
    // because Swift 5.6 (and lower) do not allows to override methods with
    // opaque return type :(
    
    open func imageModifier(_ image: Image) -> AnyView {
        AnyView(
            image
                .resizable()
                .antialiased(true)
        )
    }

    open func imageViewModifier<V: View>(_ view: V) -> AnyView {
        AnyView(view)
    }
    
    public var imageView: some View {
        imageViewModifier(
            imageModifier(image)
                .foregroundColor(imageColor)
                .aspectRatio(nil, contentMode: .fit)
                .frame(width: imageSize.width, height: imageSize.height)
        )
    }
}

#endif
