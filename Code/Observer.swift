public extension Observer
{
    func observe<O: ObservableProtocol>(_ observable: O,
                                        _ receive:
            @escaping (O.UpdateType) -> Void)
    {
        observable.add(self, receive)
    }
    
    func observe<
        O1: ObservableProtocol,
        O2: ObservableProtocol>(_ observable1: O1,
                                _ observable2: O2,
                                _ receive:
            @escaping (O1.UpdateType, O2.UpdateType) -> Void)
    {
        observable1.add(self)
        {
            [weak observable2] in
            
            guard let o2 = observable2 else { return }
            
            receive($0, o2.update)
        }
        
        observable2.add(self)
        {
            [weak observable1] in
            
            guard let o1 = observable1 else { return }
            
            receive(o1.update, $0)
        }
    }
    
    func observe<
        O1: ObservableProtocol,
        O2: ObservableProtocol,
        O3: ObservableProtocol>(_ observable1: O1,
                                _ observable2: O2,
                                _ observable3: O3,
                                _ receive:
            @escaping (O1.UpdateType, O2.UpdateType, O3.UpdateType) -> Void)
    {
        observable1.add(self)
        {
            [weak observable2, weak observable3] in
            
            guard let o2 = observable2, let o3 = observable3 else { return }
            
            receive($0, o2.update, o3.update)
        }
        
        observable2.add(self)
        {
            [weak observable1, weak observable3] in
            
            guard let o1 = observable1, let o3 = observable3 else { return }
            
            receive(o1.update, $0, o3.update)
        }
        
        observable3.add(self)
        {
            [weak observable1, weak observable2] in
            
            guard let o1 = observable1, let o2 = observable2 else { return }
            
            receive(o1.update, o2.update, $0)
        }
    }
    
    func stopObserving<O: ObservableProtocol>(_ observable: O)
    {
        observable.remove(self)
    }
    
    func stopAllObserving()
    {
        ObservationService.removeObserverFromAllObservables(self)
        
        for weakObservedObject in observedObjects.values
        {
            weakObservedObject.observed?.remove(self)
        }
    }
}

public protocol Observer: AnyObject {}
