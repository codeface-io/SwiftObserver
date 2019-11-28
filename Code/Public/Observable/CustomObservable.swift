public extension CustomObservable
{
    // MARK: - Observable
    
    func add(_ observer: AnyObject, receive: @escaping (Message) -> Void)
    {
        messenger.add(observer, receive: receive)
    }
    
    func remove(_ observer: AnyObject)
    {
        messenger.remove(observer)
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
