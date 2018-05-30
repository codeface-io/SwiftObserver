public let textMessenger = Messenger("")

open class Messenger<Message: Equatable>: Observable
{
    public init(_ latest: Message)
    {
        storedLatestMessage = latest
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
