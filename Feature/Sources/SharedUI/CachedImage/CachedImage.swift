import Brute
import SwiftUI

public struct CachedImage: View {
    @Environment(\.bruteContext) private var context
    
    @State private var cache = ImageCache.shared
    private let url: URL?
    
    public init(for url: URL?) {
        self.url = url
    }
    
    public var body: some View {
        if let url, let cached = cache.load(url) {
            Image(uiImage: cached)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            placeholder
        }
    }

    private var placeholder: some View {
        ZStack {
            Rectangle()
                .fill(context.color.accentBackground)
            
            Image(systemName: "mic.fill")
                .font(.system(size: 32))
                .foregroundStyle(context.color.accentForeground)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
