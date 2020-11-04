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
    func observeOnce(_ receive: @escaping (Message, AnyAuthor) -> Void) -> AdhocObserver
    {
        SwiftObserver.observeOnce(self, receive: receive)
    }
    
    @discardableResult
    func observeOnce(_ receive: @escaping (Message) -> Void) -> AdhocObserver
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
                                       receive: @escaping (O.Message) -> Void) -> AdhocObserver
{
    let adhocObserver = AdhocObserver()
    
    adhocObserver.observe(observabe)
    {
        adhocObserver.stopObserving()
        receive($0)
    }
    
    return adhocObserver
}

@discardableResult
public func observeOnce<O: Observable>(_ observabe: O,
                                       receive: @escaping (O.Message, AnyAuthor) -> Void) -> AdhocObserver
{
    let adhocObserver = AdhocObserver()
    
    adhocObserver.observe(observabe)
    {
        adhocObserver.stopObserving()
        receive($0, $1)
    }
    
    return adhocObserver
}
