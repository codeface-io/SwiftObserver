public extension Observer
{
    func isObserving<O: ObservableObject>(_ observable: O) -> Bool
    {
        observable.messenger.isConnected(to: receiver)
    }
    
    func observe<O: ObservableObject>(_ observable: O,
                                receive: @escaping (O.Message, AnyAuthor) -> Void)
    {
        let messenger = observable.messenger
        let connection = messenger.connect(receiver, receive: receive)
        receiver.retain(connection)
    }
    
    func observe<O: ObservableObject>(_ observable: O,
                                receive: @escaping (O.Message) -> Void)
    {
        let messenger = observable.messenger
        let connection = messenger.connect(receiver, receive: receive)
        receiver.retain(connection)
    }
    
    func stopObserving<O: ObservableObject>(_ observable: O?)
    {
        observable.forSome
        {
            receiver.disconnectMessenger(with: $0.messenger.key)
        }
    }
    
    func stopObserving()
    {
        receiver.disconnectAllMessengers()
    }
}

public protocol Observer: AnyObject
{
    var receiver: Receiver { get }
}
