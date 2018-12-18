public extension CustomObservable
{
    // MARK: - Convenience
    
    public var remembersLatestMessage: Bool
    {
        get { return messenger.remembersLatestMessage }
        set { messenger.remembersLatestMessage = newValue }
    }
    
    // MARK: - Observable
    
    public var latestMessage: Message
    {
        return messenger.latestMessage
    }
    
    func add(_ observer: AnyObject, receive: @escaping (Message) -> Void)
    {
        messenger.add(observer, receive: receive)
    }
    
    func remove(_ observer: AnyObject)
    {
        messenger.remove(observer)
    }

    func removeObservers()
    {
        messenger.removeObservers()
    }

    func removeDeadObservers()
    {
        messenger.removeDeadObservers()
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
