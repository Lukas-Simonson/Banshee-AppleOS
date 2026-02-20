import Foundation

public protocol AudioServiceContract: AnyObject, Sendable {
    var delegate: AudioServiceDelegateContract? { get set }
    
    func start(_ url: URL, token: String) async throws
    func setMedia(with data: AudioData) async
    
    func play() async
    func pause() async
    func stop(notify: Bool) async
    func skipForward() async
    func skipBackward() async
    
    func seek(to time: Int) async
    func awaitReadyToPlay() async
}
