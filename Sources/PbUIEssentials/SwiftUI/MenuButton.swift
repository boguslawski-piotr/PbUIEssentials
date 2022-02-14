import SwiftUI

public struct MenuButton<Content>: View where Content: View {
    public var systemImage: String
    public var imageColor: Color?
    public var imageScale: Image.Scale
    public var title: String
    
    @ViewBuilder public var content: () -> Content

    public init(systemImage: String, imageColor: Color? = .accentColor, imageScale: Image.Scale = .large, title: String = "", content: @escaping () -> Content) {
        self.systemImage = systemImage
        self.imageColor = imageColor
        self.imageScale = imageScale
        self.title = title
        self.content = content
    }
    
    public var body: some View {
        SwiftUI.Menu {
            content()
        } label: {
            Label(title, systemImage: systemImage)
                .imageScale(imageScale)
                .foregroundColor(imageColor)
        }
    }
}
