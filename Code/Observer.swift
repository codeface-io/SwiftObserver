public extension Observer
{
    func observe<O: Observable>(_ observable: O,
                                select event: O.UpdateType,
                                receive: @escaping () -> Void)
        where O.UpdateType: Equatable
    {
        observable.add(self, filter: { $0 == event }) { _ in receive() }
    }
    
    func observe<O: Observable>(_ observable: O,
                                filter keep: @escaping (O.UpdateType) -> Bool = { _ in true },
                                receive: @escaping (O.UpdateType) -> Void)
    {
        observable.add(self, filter: keep, receive: receive)
    }
    
    func observe<O1: Observable, O2: Observable>(
        _ observable1: O1,
        _ observable2: O2,
        _ receive: @escaping (O1.UpdateType, O2.UpdateType) -> Void)
    {
        observable1.add(self)
        {
            [weak observable2] in
            
            guard let o2 = observable2 else { return }
            
            receive($0, o2.latestUpdate)
        }
        
        observable2.add(self)
        {
            [weak observable1] in
            
            guard let o1 = observable1 else { return }
            
            receive(o1.latestUpdate, $0)
        }
    }
    
    func observe<O1: Observable, O2: Observable, O3: Observable>(
        _ observable1: O1,
        _ observable2: O2,
        _ observable3: O3,
        _ receive: @escaping (O1.UpdateType, O2.UpdateType, O3.UpdateType) -> Void)
    {
        observable1.add(self)
        {
            [weak observable2, weak observable3] in
            
            guard let o2 = observable2, let o3 = observable3 else { return }
            
            receive($0, o2.latestUpdate, o3.latestUpdate)
        }
        
        observable2.add(self)
        {
            [weak observable1, weak observable3] in
            
            guard let o1 = observable1, let o3 = observable3 else { return }
            
            receive(o1.latestUpdate, $0, o3.latestUpdate)
        }
        
        observable3.add(self)
        {
            [weak observable1, weak observable2] in
            
            guard let o1 = observable1, let o2 = observable2 else { return }
            
            receive(o1.latestUpdate, o2.latestUpdate, $0)
        }
    }
    
    func stopObserving<O: Observable>(_ observable: O?)
    {
        observable?.remove(self)
    }
    
    func stopObservingDeadObservables()
    {
        ObservationService.removeObservationsOfDeadObservables()
    }
    
    func stopAllObserving()
    {
        ObservationService.removeObserver(self)
    }
}

public protocol Observer: AnyObject {}
