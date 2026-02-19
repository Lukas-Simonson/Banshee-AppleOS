import Core
import Business
import MediaPlayer

struct AudioInfoService {
    private var info = [String: Any]()
    private var center: MPNowPlayingInfoCenter = .default()
    
    mutating func update(with data: AudioData) {
        info[MPMediaItemPropertyTitle] = data.title
        info[MPMediaItemPropertyPlaybackDuration] = Double(data.totalDuration)
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = Float64(data.watchTime ?? 0)
        
        if let artwork = data.image {
            info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(
                boundsSize: artwork.size,
                requestHandler: { _ in artwork }
            )
        }
        
        center.nowPlayingInfo = info
    }
    
    mutating func update(duration: Int, rate: Float) {
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = Float64(duration)
        info[MPNowPlayingInfoPropertyPlaybackRate] = rate
        
        center.nowPlayingInfo = info
    }
}
