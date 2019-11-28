public extension Observer
{
    func observe<O: Observable>(_ observable: O,
                                receive: @escaping (O.Message) -> Void)
    {
        observable.add(self, receive: receive)
    }
    
    func observe<O1: Observable, O2: Observable>(
        _ observable1: O1,
        _ observable2: O2,
        _ receive: @escaping (O1.Message, O2.Message) -> Void)
    {
        observable1.add(self)
        {
            [weak observable2] in
            
            guard let o2 = observable2 else { return }
            
            receive($0, o2.latestMessage)
        }
        
        observable2.add(self)
        {
            [weak observable1] in
            
            guard let o1 = observable1 else { return }
            
            receive(o1.latestMessage, $0)
        }
    }
    
    func observe<O1: Observable, O2: Observable, O3: Observable>(
        _ observable1: O1,
        _ observable2: O2,
        _ observable3: O3,
        _ receive: @escaping (O1.Message, O2.Message, O3.Message) -> Void)
    {
        observable1.add(self)
        {
            [weak observable2, weak observable3] in
            
            guard let o2 = observable2, let o3 = observable3 else { return }
            
            receive($0, o2.latestMessage, o3.latestMessage)
        }
        
        observable2.add(self)
        {
            [weak observable1, weak observable3] in
            
            guard let o1 = observable1, let o3 = observable3 else { return }
            
            receive(o1.latestMessage, $0, o3.latestMessage)
        }
        
        observable3.add(self)
        {
            [weak observable1, weak observable2] in
            
            guard let o1 = observable1, let o2 = observable2 else { return }
            
            receive(o1.latestMessage, o2.latestMessage, $0)
        }
    }
    
    func stopObserving<O: Observable>(_ observable: O?)
    {
        observable?.remove(self)
    }
    
    func stopObserving()
    {
        ObservationService.remove(observer: self)
    }
}

public protocol Observer: AnyObject {}

public func stopAllAbandonedObservations()
{
    ObservationService.removeDeadObservers()
}
