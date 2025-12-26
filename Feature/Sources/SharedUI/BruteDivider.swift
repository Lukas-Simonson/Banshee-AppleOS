import Brute
import SwiftUI

public struct BruteDivider: View {
    @Environment(\.bruteContext) private var context
    
    public init() {}
    
    public var body: some View {
        Rectangle()
            .fill(context.color.border)
            .frame(height: context.dimen.borderWidth)
    }
}
