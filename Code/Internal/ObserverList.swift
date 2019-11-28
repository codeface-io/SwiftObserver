 import SwiftyToolz
 
 class ObserverList<Message>
 {
    // MARK: - Manage Observers
    
    func add(_ observer: AnyObserver, receive: @escaping (Message) -> Void)
    {
        observers[key(observer)] = ObserverInfo(observer: observer, receive: receive)
    }
    
    func remove(_ observer: AnyObserver)
    {
        observers[key(observer)] = nil
    }
    
    // MARK: - Dispatch Message to Observers
    
    func receive(_ message: Message)
    {
        messageQueue.append(message)
        
        if messageQueue.count > 1 { return }
        
        while let message = messageQueue.first
        {
            for (observerKey, observerInfo) in observers
            {
                guard observerInfo.observer != nil else
                {
                    log(warning: "Tried so send message to dead observer. Will remove observer.")
                    observers[observerKey] = nil
                    continue
                }
                
                observerInfo.receive(message)
            }
            
            messageQueue.removeFirst()
        }
    }
    
    private var messageQueue = [Message]()
    
    // MARK: - Store Observers
    
    private var observers = [ObserverKey: ObserverInfo]()
    
    private class ObserverInfo
    {
        init(observer: AnyObserver, receive: @escaping (Message) -> Void)
        {
            self.observer = observer
            self.receive = receive
        }
        
        weak var observer: AnyObserver?
        let receive: (Message) -> Void
    }
}
