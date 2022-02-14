import SwiftUI
import PbEssentials

public struct AppIcon: View {
    public var systemImage: String
    public var imageColor: Color?
    public var versionInfo: Bool
    public var progressView: Bool

    public init(systemImage: String, imageColor: Color? = .accentColor, versionInfo: Bool = true, progressView: Bool = false) {
        self.systemImage = systemImage
        self.imageColor = imageColor
        self.versionInfo = versionInfo
        self.progressView = progressView
    }
    
    public var body: some View {
        VStack {
            Image(systemName: systemImage)
                .resizable()
                .foregroundColor(imageColor)
                .aspectRatio(nil, contentMode: .fit)
            if versionInfo {
                Text(Bundle.main.displayName).font(.largeTitle).padding(.top, 10)
                Text(Bundle.main.version)
                Text(Bundle.main.copyright)
            }
            if progressView {
                ProgressView()
            }
        }
    }
}
