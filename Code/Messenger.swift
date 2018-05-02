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
    public init(_ initialLast: Message)
    {
        storedLastMessage = initialLast
    }
    
    public func add(_ observer: AnyObject,
                    for message: Message,
                    receive: @escaping () -> Void)
    {
        add(observer)
        {
            if $0 == message
            {
                receive()
            }
        }
    }
    
    public func send(_ update: Message)
    {
        storedLastMessage = update
        
        ObservationService.send(update, toObserversOf: self)
    }
    
    public var update: Message { return storedLastMessage }
    public var lastMessage: Message { return storedLastMessage }
    
    private var storedLastMessage: Message
}
