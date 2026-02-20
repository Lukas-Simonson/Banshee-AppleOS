import Brute
import Core
import SharedUI
import SwiftUI

struct PodcastDetailSettingsPopup: View {
    
    @Environment(\.bruteContext) private var context
    @Environment(\.userRole) private var userRole
    
    @Binding var order: Episode.Order
    
    let onEditConfig: () -> Void
    
    var body: some View {
        BruteStyle {
            VStack {
                BruteSection("Sort Order") {
                    VStack(spacing: context.dimen.paddingSmall) {
                        pickerRow(title: "Title", orderType: .title)
                        pickerRow(title: "Date", orderType: .date)
                        pickerRow(title: "Season / Episode", orderType: .seasonEpisode)
                    }
                }
                
                if userRole == .admin {
                    BruteSection("Admin") {
                        Button(
                            action: onEditConfig,
                            label: {
                                Text("Edit Podcast Config")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        )
                    }
                }
            }
            .padding([.horizontal, .bottom], context.dimen.paddingMedium)
            .padding(.top, context.dimen.paddingLarge)
        }
    }
    
    private func pickerRow(title: LocalizedStringResource, orderType: OrderType) -> some View {
        switch (order, orderType) {
            case (.title(let asc), .title):
                Button(
                    action: { order = .title(asc: !asc) },
                    label: { pickerRowLabel(title: title, selected: true, asc: asc) }
                )
            case (.date(let asc), .date):
                Button(
                    action: { order = .date(asc: !asc) },
                    label: { pickerRowLabel(title: title, selected: true, asc: asc) }
                )
            case (.seasonEpisode(let asc), .seasonEpisode):
                Button(
                    action: { order = .seasonEpisode(asc: !asc) },
                    label: { pickerRowLabel(title: title, selected: true, asc: asc) }
                )
            default:
                Button(
                    action: { order = orderType.ascending },
                    label: { pickerRowLabel(title: title) }
                )
        }
    }
    
    private func pickerRowLabel(title: LocalizedStringResource, selected: Bool = false, asc: Bool = true) -> some View {
        HStack {
            Text(title)
            Spacer()
            if selected {
                Image(systemName: asc ? "arrow.up" : "arrow.down")
                    .bold()
                    .transition(.symbolEffect)
                    
            }
        }
        .contentTransition(.symbolEffect(.replace))
    }

    enum OrderType {
        case title
        case date
        case seasonEpisode
        
        var ascending: Episode.Order {
            switch self {
                case .title: .title(asc: true)
                case .date: .date(asc: true)
                case .seasonEpisode: .seasonEpisode(asc: true)
            }
        }
    }
}

#Preview {
    @Previewable @State var order = Episode.Order.title(asc: true)
    
    PodcastDetailSettingsPopup(order: $order, onEditConfig: { })
}
