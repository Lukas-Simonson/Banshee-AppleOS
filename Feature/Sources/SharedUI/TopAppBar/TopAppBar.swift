import Brute
import SwiftUI

public struct TopAppBar<Leading: View, Trailing: View>: View {
    
    @Environment(\.bruteContext) private var context
    
    let title: String
    let mode: Mode
    
    let leading: () -> Leading
    let trailing: () -> Trailing
    
    private init(title: String, mode: Mode, leading: @escaping () -> Leading, trailing: @escaping () -> Trailing) {
        self.title = title
        self.mode = mode
        self.leading = leading
        self.trailing = trailing
    }
    
    public var body: some View {
        VStack {
            Group {
                switch mode {
                    case .titleOnly: titleOnlyView
                    case .leadingAndTitle: leadingAndTitleView
                    case .trailingAndTitle: trailingAndTitleView
                    case .all: allViews
                }
            }
            .padding([.horizontal], context.dimen.paddingMedium)
            
            BruteDivider()
        }
        .background(context.color.background)
    }
    
    private var titleOnlyView: some View {
        Text(title)
            .font(context.font.title)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .center)
    }
    
    private var leadingAndTitleView: some View {
        HStack(alignment: .center, spacing: context.dimen.paddingSmall) {
            leading()
            Spacer()
            Text(title)
                .font(context.font.title)
                .multilineTextAlignment(.trailing)
        }
    }
    
    private var trailingAndTitleView: some View {
        HStack(alignment: .center, spacing: context.dimen.paddingSmall) {
            Text(title)
                .font(context.font.title)
                .multilineTextAlignment(.leading)
            Spacer()
            trailing()
        }
    }
    
    private var allViews: some View {
        HStack(alignment: .center, spacing: context.dimen.paddingSmall) {
            leading()
            Spacer()
            Text(title)
                .font(context.font.header)
                .multilineTextAlignment(.center)
            Spacer()
            trailing()
        }
    }
    
    enum Mode {
        case titleOnly
        case leadingAndTitle
        case trailingAndTitle
        case all
    }
}

extension TopAppBar {
    public init(title: String) where Leading == EmptyView, Trailing == EmptyView {
        self.title = title
        self.mode = .titleOnly
        self.leading = EmptyView.init
        self.trailing = EmptyView.init
    }
    
    public init(
        title: String,
        leading: @escaping () -> Leading
    ) where Trailing == EmptyView {
        self.title = title
        self.mode = .leadingAndTitle
        self.leading = leading
        self.trailing = EmptyView.init
    }
    
    public init(
        title: String,
        trailing: @escaping () -> Trailing
    ) where Leading == EmptyView {
        self.title = title
        self.mode = .trailingAndTitle
        self.leading = EmptyView.init
        self.trailing = trailing
    }
    
    public init(
        title: String,
        leading: @escaping () -> Leading,
        trailing: @escaping () -> Trailing,
    ) {
        self.title = title
        self.mode = .all
        self.leading = leading
        self.trailing = trailing
    }
}
