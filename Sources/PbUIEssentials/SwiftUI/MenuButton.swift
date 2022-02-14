import SwiftUI

public struct MenuButton<Content>: View where Content: View {
    public var systemImage: String
    public var title: String
    
    @ViewBuilder public var content: () -> Content

    public init(systemImage: String, title: String = "", content: @escaping () -> Content) {
        self.systemImage = systemImage
        self.title = title
        self.content = content
    }
    
    public var body: some View {
        SwiftUI.Menu {
            content()
        } label: {
            Label(title, systemImage: systemImage)
        }
    }
}
