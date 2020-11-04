extension Observable
{
    func observed() -> ObservationTransformer<Message>
    {
        ObservationTransformer
        {
            receive in FreeObserver.shared.observe(self, receive: receive)
        }
    }
    
    func observed(_ receive: @escaping (Message, AnyAuthor) -> Void)
    {
        FreeObserver.shared.observe(self, receive: receive)
    }
    
    func observed(_ receive: @escaping (Message) -> Void)
    {
        FreeObserver.shared.observe(self, receive: receive)
    }
}

public func observe<O: Observable>(_ observable: O) -> ObservationTransformer<O.Message>
{
    ObservationTransformer
    {
        receive in FreeObserver.shared.observe(observable,
                                                    receive: receive)
    }
}

public func observe<O: Observable>(_ observable: O,
                                   receive: @escaping (O.Message, AnyAuthor) -> Void)
{
    FreeObserver.shared.observe(observable, receive: receive)
}

public func observe<O: Observable>(_ observable: O,
                                   receive: @escaping (O.Message) -> Void)
{
    FreeObserver.shared.observe(observable, receive: receive)
}
