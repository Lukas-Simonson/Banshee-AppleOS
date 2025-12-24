public protocol AudioServiceDelegateContract {
    func playerDidUpdateDuration(_ newDuration: Int)
    func playerDidResume()
    func playerDidPause()
    func playerDidStop()
    
    func playerDidFinish()
    func playerDidEncounterError(_ error: Error?)
}
