/// Swift PbUIEssentials
/// Copyright (c) Piotr Boguslawski
/// MIT license, see License.md file for details.

#if os(macOS)

import SwiftUI
import PbEssentials

open class PbAlert: PbAuxiliaryModalWindow {
    // MARK: Public interface

    public struct Button: Hashable, Equatable {
        public var title: String
        public var role: ButtonRoleEx

        public init(_ title: String, _ role: ButtonRoleEx = .secondary) {
            self.title = title
            self.role = role
        }
    }
    
    public init(_ message: String, comment: String = "", buttons: [Button]? = nil, width: Range<CGFloat>? = nil, image: Image? = nil) {
        self.message = message
        self.comment = comment
        self.buttons = buttons ?? [Button("OK", .primary)]
        self.width = width ?? .init(uncheckedBounds: (300, 600))
        super.init(image)
    }
    
    public convenience init(error: Error) {
        self.init(PbError(error).shortDescription)
        drawOverlayImage = true
    }
    
    // MARK: Implementation
    
    public var message: String
    public var comment: String
    public var buttons: [Button]
    public var width: Range<CGFloat>

    open lazy var overlayImage = Image(systemName: PbAuxiliaryModalWindow.systemImageForError)
    open lazy var overlayImageSize = CGSize(width: imageSize.width / 3, height: imageSize.width / 3)
    open lazy var overlayImageColor = Color.red
    
    public var drawOverlayImage = false

    open override func imageViewModifier<V: View>(_ view: V) -> AnyView {
        if !drawOverlayImage {
            return AnyView(view)
        }
        return AnyView(
            ZStack {
                view
                HStack {
                    overlayImage
                        .resizable()
                        .aspectRatio(nil, contentMode: .fit)
                        .foregroundColor(overlayImageColor)
                        .frame(width: overlayImageSize.width, height: overlayImageSize.height, alignment: .bottomTrailing)
                }
                .frame(width: imageSize.width, height: imageSize.height, alignment: .bottomTrailing)
            }
        )
    }
    
    // TODO: obsluzyc ustawianie wielkosci okna...

    open override func makeWindowController() -> PbWindowController {
        let controller = PbWindowController(
            AlertView()
                .environmentObject(self)
                .frame(minWidth: width.lowerBound, maxWidth: width.upperBound)
        )
        controller.viewWindow?.animationBehavior = .alertPanel
        return controller
    }
    
    struct AlertView: View {
        @EnvironmentObject var windowController: PbWindowController
        @EnvironmentObject var data: PbAlert
        
        var body: some View {
            HStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 0) {
                    data.imageView
                    
                    if !data.message.isEmpty {
                        Text(markdown: data.message)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                            .padding(.top, 20)
                    }
                    if !data.comment.isEmpty {
                        Text(markdown: data.comment, configuration: .init(bodyFont: .callout, bodyColor: .secondary))
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                            .padding(.top, 10)
                    }

                    SwiftUI.Button("") {
                        windowController.endModal(.cancel)
                    }
                    .keyboardShortcut(.escape, modifiers: [])
                    .frame(height: 0)
                    .hidden()
                    
                    HStack {
                        ForEach(0...data.buttons.count - 1, id: \.self) { i in
                            PbButton(data.buttons[i].title, role: data.buttons[i].role) {
                                windowController.endModal(.init(rawValue: NSApplication.ModalResponse.alertFirstButtonReturn.rawValue + i))
                            }
                            .modifier(if: data.buttons[i].role == .primary) {
                                $0.keyboardShortcut(.return, modifiers: [])
                            }
                        }
                    }
                    .padding(.top, 20)
                }
                
                Spacer()
            }
            .padding(.top, 30)
            .padding(.bottom, 20)
            .padding(.horizontal, 20)
            .background(.ultraThickMaterial)
        }
    }
}

#endif

