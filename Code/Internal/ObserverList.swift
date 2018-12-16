 import SwiftyToolz
 
 class ObserverList<Update>
 {
    func add(_ observer: AnyObject, receive: @escaping (Update) -> Void)
    {
        observers[hashValue(observer)] = ObserverInfo(observer: observer,
                                                      receive: receive)
    }
    
    func remove(_ observer: AnyObject)
    {
        observers[hashValue(observer)] = nil
    }
    
    func removeNilObservers()
    {
        observers.remove { $0.observer == nil }
    }
    
    func removeAll()
    {
        observers.removeAll()
    }
    
    var hashValues: [HashValue]
    {
        return Array(observers.keys)
    }
    
    var hashValuesOfNilObservers: [HashValue]
    {
        let keys = observers.compactMap
        {
            return $1.observer == nil ? $0 : nil
        }
        
        return Array(keys)
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
