import Cobweb

public extension Cobweb.URL {
    func also(_ perform: (Self) -> Void) -> Self {
        perform(self)
        return self
    }
    
    func also(_ perform: () -> Void) -> Self {
        perform()
        return self
    }
}

public extension Cobweb.HTTP.Request {
    func also(_ perform: (Self) -> Void) -> Self {
        perform(self)
        return self
    }
    
    func also(_ perform: () -> Void) -> Self {
        perform()
        return self
    }
}

public extension Cobweb.HTTP.Response {
    func also(_ perform: (Self) -> Void) -> Self {
        perform(self)
        return self
    }
    
    func also(_ perform: () -> Void) -> Self {
        perform()
        return self
    }
}

