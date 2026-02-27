import Audio
import Brute
import Settings
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
                
                Tab(value: AppCoordinator.MainTab.settings) {
                    SettingsCoordinator.Root(
                        coordinator: app.scaffold.settingsCoordinator()
                    )
                    .toolbarVisibility(.hidden, for: .tabBar)
                }
            }
            
            BruteDivider()
            
            PlayerView(app.scaffold.audio())
            tabs
        }
        .background(context.color.background)
        .ignoresSafeArea(.keyboard, edges: .all)
    }
    
    private var tabs: some View {
        HStack {
            tab(.podcasts, title: "Podcasts", systemImage: "microphone.fill")
            tab(.settings, title: "Settings", systemImage: "gearshape.fill")
        }
        .padding([.horizontal, .top], context.dimen.paddingMedium)
    }
    
    private func tab(_ tab: AppCoordinator.MainTab, title titleKey: LocalizedStringKey, systemImage: String) -> some View {
        VStack(alignment: .center, spacing: context.dimen.paddingSmall) {
            Image(systemName: systemImage)
                .font(.system(size: 24))
                .foregroundStyle(tab == app.mainTab ? context.color.accentBackground : context.color.foreground)
            
            Text(titleKey)
                .font(.system(size: 12, design: .rounded))
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .background(context.color.background) // make full width interactable
        .onTapGesture { app.mainTab = tab }
    }
}

#Preview {
    BottomNavigation(app: AppCoordinator())
}
