/// Swift PbUIEssentials
/// Copyright (c) Piotr Boguslawski
/// MIT license, see License.md file for details.

#if os(macOS)

import SwiftUI
import PbEssentials

open class PbGetText: PbAuxiliaryModalWindow {
    // MARK: Public interface
    
    public typealias ValidatorResult = Result<String, PbError>
    public typealias Validator = (String) -> ValidatorResult
    
    public init(_ title: String, initialText: String = "", validator: Validator? = nil, okTitle: String? = nil, cancelTitle: String? = nil, width: Range<CGFloat>? = nil, image: Image? = nil) {
        self.title = title
        self.text = initialText
        self.validator = validator
        self.okTitle = okTitle ?? "OK"
        self.cancelTitle = cancelTitle ?? Bundle.main.L("Cancel")
        self.width = width ?? .init(uncheckedBounds: (350, 350))
        super.init(image)
    }
    
    open func runModal(asSheet: Bool = true, position: PbWindowController.Position = .screenCenter) -> String? {
        runModal(asSheet: asSheet, position: position) == .OK ? text : nil
    }
    
    open func runModalSheet(for window: NSWindow, critical: Bool = false) async -> String? {
        await runModalSheet(for: window, critical: critical) == .OK ? text : nil
    }

    open func runModalSheet(for window: NSWindow, critical: Bool = false, completion handler: @escaping (String?) -> Void) {
        runModalSheet(for: window, critical: critical) { [weak self] result in
            handler(result == .OK ? self?.text : nil)
        }
    }

    // MARK: Implementation

    public let title: String
    public var text: String
    public let validator: Validator?
    public let okTitle: String
    public let cancelTitle: String
    public let width: Range<CGFloat>

    open override func makeWindowController() -> PbWindowController {
        let controller = PbWindowController(
            GetTextView()
                .environmentObject(self)
                .frame(minWidth: width.lowerBound, maxWidth: width.upperBound)
        )
        controller.viewWindow?.animationBehavior = .documentWindow
        return controller
    }
    
    struct GetTextView: View {
        @EnvironmentObject var windowController: PbWindowController
        @EnvironmentObject var data: PbGetText
        
        @State var text = ""
        @State var error = ""
        
        var body: some View {
            VStack(spacing: 0) {
                data.imageView
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(markdown: data.title)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    TextField("", text: $text)
                        .PbTextFieldStyle()
                        .onSubmit { ok() }
                        .onChange(of: text, perform: { _ in error = "" })
                    
                    if !error.isEmpty {
                        FillingVStack(horizontalAlignment: .center, verticalAlignment: .top, spacing: 0) {
                            Text(markdown: error, configuration: .init(bodyFont: .callout, bodyColor: .red))
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.bottom, -10)
                    }
                }
                .padding(.top, 20)
                
                HStack {
                    PbButton(data.cancelTitle, role: .cancel) { windowController.endModal(.cancel) }
                    .keyboardShortcut(.escape, modifiers: [])
                    
                    PbButton(data.okTitle, role: .primary) { ok() }
                    .disabled(text.isEmpty)
                    .keyboardShortcut(.return, modifiers: [])
                }
                .padding(.top, 20)
            }
            .padding(.top, 30)
            .padding(.bottom, 20)
            .padding(.horizontal, 30)
            .background(.ultraThickMaterial)
            .onAppear(perform: { text = data.text })
        }
        
        func ok() {
            let text = text.trimmingCharacters(in: .illegalCharacters)
            if !text.isEmpty {
                switch data.validator?(text) ?? .success(text) {
                case .success(let validText):
                    data.text = validText
                    windowController.endModal(.OK)
                case .failure(let error):
                    self.error = error.shortDescription
                    NSSound.beep()
                }
            }
        }
    }
}

#endif
