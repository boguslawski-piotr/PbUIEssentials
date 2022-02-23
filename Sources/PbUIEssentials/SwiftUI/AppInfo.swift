/// Swift PbUIEssentials
/// Copyright (c) Piotr Boguslawski
/// MIT license, see License.md file for details.

import SwiftUI
import PbEssentials

public struct AppInfo: View {
    // MARK: Public interface
    
    public init(image: Image, message: String = "", versionInfo: Bool = true, copyrightInfo: Bool = true, progressView: Bool = false) {
        self.init(image: image, systemImage: "", message: message, versionInfo: versionInfo, copyrightInfo: copyrightInfo, progressView: progressView)
    }

    public init(systemImage: String, message: String = "", versionInfo: Bool = true, copyrightInfo: Bool = true, progressView: Bool = false) {
        self.init(image: nil, systemImage: systemImage, message: message, versionInfo: versionInfo, copyrightInfo: copyrightInfo, progressView: progressView)
    }
    
    public func imageColor(_ color: Color) -> AppInfo {
        imageData.color = color
        return self
    }
    
    public func imageFrame(width: CGFloat = 0, height: CGFloat = 0) -> AppInfo {
        imageData.size = CGSize(width: width == 0 ? height : width, height: height == 0 ? width : height)
        return self
    }
    
    public func imageAspectRatio(_ aspectRatio: CGFloat? = nil, contentMode: ContentMode) -> AppInfo {
        imageData.aspectRatio = aspectRatio
        imageData.contentMode = contentMode
        return self
    }

    // MARK: Implementation
    
    private init(image: Image? = nil, systemImage: String = "", message: String = "", versionInfo: Bool = true, copyrightInfo: Bool = true, progressView: Bool = false) {
        self.image = image ?? Image(systemName: systemImage)
        self.message = message
        self.versionInfo = versionInfo
        self.copyrightInfo = copyrightInfo
        self.progressView = progressView
    }
    
    private class ImageData {
        var color: Color = .accentColor
        var size: CGSize = CGSize(width: 64, height: 64)
        var aspectRatio: CGFloat? = nil
        var contentMode: ContentMode = .fit
    }
    
    private var image: Image
    private var imageData = ImageData()

    private var message: String
    private var versionInfo: Bool
    private var copyrightInfo: Bool
    private var progressView: Bool
    
    @ViewBuilder
    private func imageView() -> some View {
        image
            .resizable()
            .antialiased(true)
            .aspectRatio(imageData.aspectRatio, contentMode: imageData.contentMode)
            .foregroundColor(imageData.color)
            .modifier(if: imageData.size != .zero) {
                $0.frame(width: imageData.size.width, height: imageData.size.height)
            }
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            imageView()

            if versionInfo {
                Text(Bundle.main.displayName).font(.largeTitle).padding(.top, 20)
                Text(Bundle.main.version).font(.headline)
            }

            if !message.isEmpty {
                Text(markdown: message)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 20)
            }

            if copyrightInfo {
                Text(Bundle.main.copyright).padding(.top, 20).font(.subheadline)
            }

            if progressView {
                ProgressView().padding(.top, 20)
            }
        }
    }
}

