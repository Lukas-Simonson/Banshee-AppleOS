import Core
import Brute
import NoticeMe
import SwiftUI

struct ErrorNotice: Noticeable {

    @NoticeCancellation var cancellation

    var noticeInfo = NoticeInfo(
        alignment: .top,
        duration: .seconds(5),
        transition: .scale(scale: 0, anchor: .top)
    )

    var error: CoreError

    var body: some View {
        BruteNotice("Error: \(error.errorCode)", systemImage: "exclamationmark.triangle.fill", fill: Color.red) {
            VStack(alignment: .leading, spacing: 4) {
                Text(error.errorDescription ?? error.localizedDescription)
            }
        }
        .padding()
        .onTapGesture { cancellation() }
    }
}

#Preview {
    
    @Previewable @State var manager = NoticeManager()
    
    NoticeHandler(manager) {
        Button("Error") {
            manager.queueNotice(ErrorNotice(error: CoreError.diskFull(layer: .app, feature: .audio)))
        }
    }
}
