public extension Observer
{
    func isObserving<O: Observable>(_ observable: O) -> Bool
    {
        observable.messenger.isConnected(to: receiver)
    }
    
    func observe<O: Observable>(_ observable: O,
                                receive: @escaping (O.Message, AnyAuthor) -> Void)
    {
        let messenger = observable.messenger
        let connection = Connection(messenger: messenger, receiver: receiver)
        messenger.register(connection, receive: receive)
        receiver.retain(connection)
    }
    
    func observe<O: Observable>(_ observable: O,
                                receive: @escaping (O.Message) -> Void)
    {
        let messenger = observable.messenger
        let connection = Connection(messenger: messenger, receiver: receiver)
        messenger.register(connection, receive: receive)
        receiver.retain(connection)
    }
    
    func stopObserving<O: Observable>(_ observable: O?)
    {
        observable.forSome
        {
            receiver.closeConnection(for: $0.messenger.key)
        }
    }
    
    func stopObserving()
    {
        receiver.closeAllConnections()
    }
}

public protocol Observer
{
    var receiver: Receiver { get }
}
