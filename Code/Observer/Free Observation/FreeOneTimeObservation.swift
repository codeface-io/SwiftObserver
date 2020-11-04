extension Observable
{
    func observeOnce() -> ObservationTransformer<Message>
    {
        ObservationTransformer
        {
            receive in SwiftObserver.observeOnce(self, receive: receive)
        }
    }
    
    @discardableResult
    func observeOnce(_ receive: @escaping (Message, AnyAuthor) -> Void) -> FreeObserver
    {
        SwiftObserver.observeOnce(self, receive: receive)
    }
    
    @discardableResult
    func observeOnce(_ receive: @escaping (Message) -> Void) -> FreeObserver
    {
        SwiftObserver.observeOnce(self, receive: receive)
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
