extension Observable
{
    func observedOnce() -> ObservationTransformer<Message>
    {
        ObservationTransformer
        {
            receive in observeOnce(self, receive: receive)
        }
    }
    
    @discardableResult
    func observedOnce(_ receive: @escaping (Message, AnyAuthor) -> Void) -> FreeObserver
    {
        observeOnce(self, receive: receive)
    }
    
    @discardableResult
    func observedOnce(_ receive: @escaping (Message) -> Void) -> FreeObserver
    {
        observeOnce(self, receive: receive)
    }
}

public func observeOnce<O: Observable>(_ observable: O) -> ObservationTransformer<O.Message>
{
    ObservationTransformer
    {
        receive in observeOnce(observable, receive: receive)
    }
}

@discardableResult
public func observeOnce<O: Observable>(_ observabe: O,
                                       receive: @escaping (O.Message) -> Void) -> FreeObserver
{
    let observer = FreeObserver()
    
    observer.observe(observabe)
    {
        observer.stopObserving()
        receive($0)
    }
    
    return observer
}

@discardableResult
public func observeOnce<O: Observable>(_ observabe: O,
                                       receive: @escaping (O.Message, AnyAuthor) -> Void) -> FreeObserver
{
    let observer = FreeObserver()
    
    observer.observe(observabe)
    {
        observer.stopObserving()
        receive($0, $1)
    }
    
    return observer
}
