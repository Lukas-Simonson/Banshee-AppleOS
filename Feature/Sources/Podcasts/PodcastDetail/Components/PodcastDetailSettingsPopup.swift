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
                        pickerRow(title: "Title", value: .title)
                        pickerRow(title: "Date", value: .date)
                        pickerRow(title: "Season / Episode", value: .seasonEpisode)
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
    
    private func pickerRow(title: LocalizedStringResource, value: Episode.Order) -> some View {
        Button(
            action: { order = value },
            label: {
                HStack {
                    Text(title)
                    Spacer()
                    if order == value {
                        Image(systemName: "checkmark")
                            .bold()
                    }
                }
            }
        )
    }
}

#Preview {
    @Previewable @State var order = Episode.Order.title
    
    PodcastDetailSettingsPopup(order: $order, onEditConfig: { })
}
