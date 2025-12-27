public protocol AudioServiceDelegateContract {
    func playerDidUpdateTimePlayed(_ time: Int)
    func playerDidResume()
    func playerDidPause()
    func playerDidStop()
    
    func playerDidFinish(_ time: Int)
    func playerDidEncounterError(_ error: Error?)
}
