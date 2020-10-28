public extension Observable
{
    func receive(_ receive: @escaping (Message, AnyAuthor) -> Void)
    {
        observe(self, receive: receive)
    }
    
    func receive(_ receive: @escaping (Message) -> Void)
    {
        observe(self, receive: receive)
    }
}

public func observe<O: Observable>(_ observable: O) -> ObservationTransformer<O.Message>
{
    ObservationTransformer
    {
        receive in observe(observable, receive: receive)
    }
}

public func observe<O: Observable>(_ observable: O,
                                   receive: @escaping (O.Message, AnyAuthor) -> Void)
{
    AnonymousObserver.shared.observe(observable, receive: receive)
}

public func observe<O: Observable>(_ observable: O,
                                   receive: @escaping (O.Message) -> Void)
{
    AnonymousObserver.shared.observe(observable, receive: receive)
}

public class AnonymousObserver: Observer
{
    public static let shared = AnonymousObserver()
    
    private init() {}
    
    public let receiver = Receiver()
}
