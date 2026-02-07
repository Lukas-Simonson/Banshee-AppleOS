import Brute
import SwiftUI

public extension ButtonStyle where Self == IconButtonStyle {
    static func icon(size: IconButtonStyle.Size, background: Color? = nil, foreground: Color? = nil) -> Self {
        IconButtonStyle(size: size, backgroundColor: background, foregroundColor: foreground)
    }
}

public extension ButtonStyle where Self == FlatIconButtonStyle {
    static func flatIcon(size: FlatIconButtonStyle.Size, background: Color? = nil, foreground: Color? = nil) -> Self {
        FlatIconButtonStyle(size: size, backgroundColor: background, foregroundColor: foreground)
    }
}

public struct IconButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.bruteContext) private var context
    
    var size: Size
    var backgroundColor: Color?
    var foregroundColor: Color?
    
    public func makeBody(configuration: Configuration) -> some View {
        
        let values = size.values
        
        return configuration.label
            .labelStyle(.iconOnly)
            .font(.system(size: values.fontSize).bold())
            .frame(width: values.size, height: values.size, alignment: .center)
            .foregroundStyle(foregroundColor ?? context.color.accentForeground)
            .background(backgroundColor ?? context.color.accentBackground)
            .bruteClipped()
            .bruteStroked()
            .offset(configuration.isPressed ? context.dimen.shadowOffset : .zero)
            .bruteShadow()
            .saturation(isEnabled ? 1.0 : 0.25)
    }
    
    public enum Size {
        case small
        case medium
        case large
        
        var values: (fontSize: CGFloat, size: CGFloat) {
            switch self {
                case .small: (18, 40)
                case .medium: (22, 50)
                case .large: (32, 64)
            }
        }
    }
}

public struct FlatIconButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.bruteContext) private var context
    
    var size: Size
    var backgroundColor: Color?
    var foregroundColor: Color?
    
    public func makeBody(configuration: Configuration) -> some View {
        
        let values = size.values
        
        return configuration.label
            .labelStyle(.iconOnly)
            .font(.system(size: values.fontSize).bold())
            .frame(width: values.size, height: values.size, alignment: .center)
            .foregroundStyle(foregroundColor ?? context.color.accentForeground)
            .background(backgroundColor ?? context.color.accentBackground)
            .bruteClipped()
            .bruteStroked()
//            .offset(configuration.isPressed ? context.dimen.shadowOffset : .zero)
//            .bruteShadow()
            .saturation(isEnabled ? 1.0 : 0.25)
    }
    
    public enum Size {
        case small
        case medium
        case large
        
        var values: (fontSize: CGFloat, size: CGFloat) {
            switch self {
                case .small: (18, 40)
                case .medium: (22, 50)
                case .large: (32, 64)
            }
        }
    }
}

#Preview {
    VStack {
        Text("Small")
        Button("Play", systemImage: "play.fill", action: {})
            .buttonStyle(IconButtonStyle(size: .small))
        
        Text("Medium")
        Button("Play", systemImage: "play.fill", action: {})
            .buttonStyle(IconButtonStyle(size: .medium))
        
        Text("Large")
        Button("Play", systemImage: "play.fill", action: {})
            .buttonStyle(IconButtonStyle(size: .large))
    }
}
