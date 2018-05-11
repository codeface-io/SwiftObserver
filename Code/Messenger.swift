public let textMessenger = Messenger("")

public extension Observer
{
    func observe<Message>(_ message: Message,
                          from messenger: Messenger<Message>,
                          receive: @escaping () -> Void)
    {
        messenger.add(self, for: message, receive: receive)
    }
}

public class Messenger<Message: Equatable>: Observable
{
    public init(_ latest: Message)
    {
        storedLatestMessage = latest
    }
    
    public func add(_ observer: AnyObject,
                    for message: Message,
                    receive: @escaping () -> Void)
    {
        add(observer, filter: { $0 == message }) { _ in receive() }
    }
    
    public func send(_ update: Message)
    {
        storedLatestMessage = update
        
        ObservationService.send(update, toObserversOf: self)
    }
    
    public var latestUpdate: Message { return storedLatestMessage }
    public var latestMessage: Message { return storedLatestMessage }
    
    private var storedLatestMessage: Message
}
