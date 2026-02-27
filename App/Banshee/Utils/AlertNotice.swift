import Core
import Brute
import NoticeMe
import SharedUI
import SwiftUI

struct AlertNotice: Noticeable {
    @Environment(\.bruteContext) private var context
    @NoticeCancellation private var cancellation
    
    let alert: CoreAlert
    let noticeInfo: NoticeInfo
    
    init(alert: CoreAlert) {
        self.alert = alert
        
        // Auto dismiss after 8 seconds if no actions are present.
        if alert.actions.isEmpty {
            self.noticeInfo = NoticeInfo(
                id: alert.id,
                alignment: .center,
                duration: .seconds(8),
                transition: .opacity
            )
        } else {
            self.noticeInfo = NoticeInfo(
                id: alert.id,
                alignment: .center,
                transition: .opacity,
            )
        }
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.25)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.opacity)
                .onTapGesture {
                    if alert.dismissible {
                        cancellation()
                    }
                }
            
            BruteCard {
                Text(alert.title)
                    .font(context.font.title)
                BruteDivider()
                Text(alert.message)
                
                ForEach(alert.actions) { action in
                    Button(
                        action: {
                            cancellation()
                            action.action()
                        },
                        label: {
                            Text(action.title)
                                .frame(maxWidth: .infinity)
                        }
                    )
                }
            }
            .padding(context.dimen.paddingLarge)
        }
        .ignoresSafeArea(.all)
    }
}

#Preview {
    
    @Previewable @State var manager = NoticeManager()
    
    BruteStyle {
        Button("Alert") {
            manager.queueNotice(
                AlertNotice(
                    alert: CoreAlert(
                        title: "Alert!",
                        message: "You have done something!",
                        actions: CoreAlert.Action(
                            title: "Ok",
                            action: { }
                        )
                    )
                )
            )
        }
        .handleNotices(from: manager)
    }
}
