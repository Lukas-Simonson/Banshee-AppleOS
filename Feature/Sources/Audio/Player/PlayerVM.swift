import Core
import Foundation
import Logging
import Observation

@MainActor @Observable
final class PlayerVM {
    
    // MARK: - Dependencies
    private let logger: Logger
    private let player: EpisodePlayerContract
    private let navigator: AudioNavigationContract
    
    // MARK: - State
    private(set) var state: AudioPlayerState?
    var isPlayerExpanded: Bool = false
    
    // MARK: - Initialization
    init(_ scaffold: AudioScaffoldContract) {
        self.logger = scaffold.logger()
        self.player = scaffold.player()
        self.navigator = scaffold.navigator()
        
        observeState()
    }
    
    // MARK: - Actions
    func play() {
        Task {
            await player.play()
        }
    }
    
    func pause() {
        Task {
            await player.pause()
        }
    }
    
    // MARK: - Private Methods
    private func observeState() {
        Task { [weak self] in
            guard let stream = self?.player.playerStateStream else { return }
            
            for await state in stream {
                guard let self else { break }
                self.state = state
                
                if let state, case .error(let e) = state.mode {
                    // Hide Player & Show Error
                    self.state = nil
                    navigator.showError(e)
                }
            }
        }
    }
}
