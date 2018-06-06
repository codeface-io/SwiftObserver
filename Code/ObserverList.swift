 import SwiftyToolz
 
 class ObserverList<Update>
 {
    func add(_ observer: AnyObject, receive: @escaping (Update) -> Void)
    {
        observers[hash(observer)] = ObserverInfo(observer: observer,
                                                 receive: receive)
    }
    
    func remove(_ observer: AnyObject)
    {
        observers[hash(observer)] = nil
    }
    
    func removeNilObservers()
    {
        observers.remove { $0.observer == nil }
    }
    
    func removeAll()
    {
        observers.removeAll()
    }
    
    var isEmpty: Bool { return observers.isEmpty }
    
    func receive(_ update: Update)
    {
        for (observerHash, observerInfo) in observers
        {
            guard observerInfo.observer != nil else
            {
                log(warning: "Tried so send update to dead observer. Will remove observer.")
                observers[observerHash] = nil
                continue
            }
            
            observerInfo.receive(update)
        }
    }
    
    private var observers = [HashValue: ObserverInfo]()
    
    private class ObserverInfo
    {
        init(observer: AnyObject, receive: @escaping (Update) -> Void)
        {
            self.observer = observer
            self.receive = receive
        }
        
        weak var observer: AnyObject?
        let receive: (Update) -> Void
    }
}
