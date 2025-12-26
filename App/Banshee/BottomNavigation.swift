import Audio
import Brute
import SharedUI
import SwiftUI

struct BottomNavigation: View {

    @Environment(\.bruteContext) private var context

    @Bindable var app: AppCoordinator

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $app.mainTab) {
                Tab(value: AppCoordinator.MainTab.podcasts) {
                    PodcastCoordinator.Root(
                        coordinator: app.scaffold.podcastCoordinator()
                    )
                    .toolbarVisibility(.hidden, for: .tabBar)
                }
            }
            
            BruteDivider()
            
            PlayerView(app.scaffold.audio())
            
            tabs
        }
        .background(context.color.background)
    }
    
    private var tabs: some View {
        HStack {
            Spacer()
            Label("Podcasts", systemImage: "microphone.fill")
                .padding(context.dimen.paddingSmall)
                .background(context.color.accentBackground)
                .foregroundStyle(context.color.accentForeground)
                .bruteClipped()
                .bruteStroked()
            Spacer()
            Label("Settings", systemImage: "gearshape.fill")
                .padding(context.dimen.paddingSmall)
                .background(context.color.accentBackground)
                .foregroundStyle(context.color.accentForeground)
                .bruteClipped()
                .bruteStroked()
            Spacer()
        }
        .padding(context.dimen.paddingMedium)
    }
}

//VStack(spacing: 0) {
//    // PodcastListScreen(app.scaffold.podcast())
//    PodcastCoordinator.Root(coordinator: app.scaffold.podcastCoordinator())
//
//    Rectangle()
//        .fill(context.color.border)
//        .frame(height: context.dimen.borderWidth)
//
//    PlayerView(app.scaffold.audio())
//        .padding(context.dimen.paddingMedium)
//        .background(context.color.background)
//
//}

#Preview {
    BottomNavigation(app: AppCoordinator())
}
