 import SwiftyToolz
 
 class ObserverList<Message>
 {
    // MARK: - Manage Observers
    
    func add(_ observer: AnyObject, receive: @escaping (Message) -> Void)
    {
        observers[hashValue(observer)] = ObserverInfo(observer: observer,
                                                      receive: receive)
    }
    
    @discardableResult
    func remove(_ observer: AnyObject) -> Bool
    {
        if observers[hashValue(observer)] != nil
        {
            observers[hashValue(observer)] = nil
            return true
        }
        
        return false
    }
    
    func removeDeadObservers()
    {
        observers.remove { $0.observer == nil }
    }
    
    func removeAll()
    {
        observers.removeAll()
    }
    
    var isEmpty: Bool { observers.isEmpty }
    
    // MARK: - Get Hash Values (for ObservationService)
    
    var hashValues: [HashValue]
    {
        Array(observers.keys)
    }
    
    var hashValuesOfNilObservers: [HashValue]
    {
        let keys = observers.compactMap
        {
            return $1.observer == nil ? $0 : nil
        }
        
        return Array(keys)
    }
    
    // MARK: - Dispatch Message to Observers
    
    func receive(_ message: Message)
    {
        messageQueue.append(message)
        
        if messageQueue.count > 1 { return }
        
        while let message = messageQueue.first
        {
            for (observerHash, observerInfo) in observers
            {
                guard observerInfo.observer != nil else
                {
                    log(warning: "Tried so send message to dead observer. Will remove observer.")
                    observers[observerHash] = nil
                    continue
                }
                
                observerInfo.receive(message)
            }
            
            // remove value AFTER all handlers were called. do NOT write `storedValue = valueQueue.removeFirst()`
            messageQueue.removeFirst()
        }
    }
    
    private var messageQueue = [Message]()
    
    // MARK: - Store Observers
    
    private var observers = [HashValue: ObserverInfo]()
    
    private class ObserverInfo
    {
        init(observer: AnyObject, receive: @escaping (Message) -> Void)
        {
            self.observer = observer
            self.receive = receive
        }
        
        weak var observer: AnyObject?
        let receive: (Message) -> Void
    }
}
