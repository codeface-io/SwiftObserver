public extension CustomObservable
{
    // MARK: - Convenience
    
    var remembersLatestMessage: Bool
    {
        get { messenger.remembersLatestMessage }
        set { messenger.remembersLatestMessage = newValue }
    }
    
    // MARK: - Observable
    
    var latestMessage: Message
    {
        messenger.latestMessage
    }
    
    func add(_ observer: AnyObject, receive: @escaping (Message) -> Void)
    {
        messenger.add(observer, receive: receive)
    }
    
    func remove(_ observer: AnyObject)
    {
        messenger.remove(observer)
    }

    func stopObservations()
    {
        messenger.stopObservations()
    }

    func stopAbandonedObservations()
    {
        messenger.stopAbandonedObservations()
    }

    func send(_ message: Message)
    {
        messenger.send(message)
    }
}

public protocol CustomObservable: Observable
{
    var messenger: Messenger<Message> { get }
}
