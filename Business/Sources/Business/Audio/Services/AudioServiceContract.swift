import Foundation

public protocol AudioServiceContract: Sendable {
    var delegate: AudioServiceDelegateContract? { get set }
    
    func start(_ url: URL, token: String) async throws
    func setMedia(with data: AudioData) async
    
    func play() async
    func pause() async
    func stop() async
    func skipForward() async
    func skipBackward() async
}
