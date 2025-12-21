import Core
import Brute
import NoticeMe
import SwiftUI

struct ErrorNotice: Noticeable {
    
    @NoticeCancellation var cancellation
    
    var noticeInfo = NoticeInfo(
        alignment: .top,
        duration: .seconds(3),
        transition: .scale(scale: 0, anchor: .top)
    )
    
    var error: LocalizedError
    
    var body: some View {
        BruteNotice("Error", systemImage: "exclamationmark.triangle.fill", fill: Color.red) {
            Text(error.errorDescription ?? error.localizedDescription)
        }
        .padding()
        .onTapGesture { cancellation() }
    }
}

#Preview {
    
    @Previewable @State var manager = NoticeManager()
    
    NoticeHandler(manager) {
        Button("Error") {
            manager.queueNotice(ErrorNotice(error: AuthRepositoryError.unableToClearSession))
        }
    }
}
