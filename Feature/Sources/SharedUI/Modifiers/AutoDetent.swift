import SwiftUI

public extension View {
    func autoDetent() -> some View {
        modifier(AutoDetent())
    }
}

struct AutoDetent: ViewModifier {
    @State private var height: CGFloat = 100
    
    func body(content: Content) -> some View {
        content.background {
            GeometryReader { proxy in
                Color.clear
                    .onAppear { height = proxy.size.height }
                    .onChange(of: proxy.size) { _, newValue in
                        height = newValue.height
                    }
            }
        }
        .presentationDetents([.height(height)])
    }
}
