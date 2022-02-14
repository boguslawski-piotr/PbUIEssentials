import SwiftUI
import PbEssentials

public struct AppInfo: View {
    public var image: String
    public var systemImage: String
    public var message: String
    public var versionInfo: Bool
    public var copyrightInfo: Bool
    public var progressView: Bool
    
    @State private var imageForegroundColor: Color = .accentColor
    
    init(image: String = "", systemImage: String = "", message: String = "", versionInfo: Bool = true, copyrightInfo: Bool = true, progressView: Bool = false) {
        self.image = image
        self.systemImage = systemImage
        self.message = message
        self.versionInfo = versionInfo
        self.copyrightInfo = copyrightInfo
        self.progressView = progressView
    }
    
    public init(image: String, message: String = "", versionInfo: Bool = true, copyrightInfo: Bool = true, progressView: Bool = false) {
        self.init(image: image, systemImage: "", message: message, versionInfo: versionInfo, copyrightInfo: copyrightInfo, progressView: progressView)
    }

    public init(systemImage: String, message: String = "", versionInfo: Bool = true, copyrightInfo: Bool = true, progressView: Bool = false) {
        self.init(image: "", systemImage: systemImage, message: message, versionInfo: versionInfo, copyrightInfo: copyrightInfo, progressView: progressView)
    }
    
    public func imageForegroundColor(_ color: Color) -> AppInfo {
        imageForegroundColor = color
        return self
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            Group {
                if !image.isEmpty {
                    Image(image)
                } else {
                    Image(systemName: systemImage)
                        .resizable()
                        .aspectRatio(nil, contentMode: .fit)
                }
            }
            .foregroundColor(imageForegroundColor)

            if versionInfo {
                Text(Bundle.main.displayName).font(.largeTitle).padding(.top, 30)
                Text(Bundle.main.version).font(.headline)
            }

            if !message.isEmpty {
                Text(markdown: message).padding(.top, 20)
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
