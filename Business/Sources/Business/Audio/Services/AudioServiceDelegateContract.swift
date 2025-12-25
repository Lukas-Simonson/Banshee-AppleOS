public protocol AudioServiceDelegateContract {
    func playerDidUpdateTimePlayed(_ time: Int)
    func playerDidResume()
    func playerDidPause()
    func playerDidStop()
    
    func playerDidFinish()
    func playerDidEncounterError(_ error: Error?)
}
