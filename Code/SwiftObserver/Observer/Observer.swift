public extension Observer
{
    /**
     Whether the `Observer` has at least one observation of the ``ObservableObject`` going
     */
    func isObserving<O: ObservableObject>(_ observable: O) -> Bool
    {
        observable.messenger.isConnected(to: receiver)
    }
    
    /**
     Receive the ``ObservableObject``'s future ``ObservableObject/Message``s together with their authors
     */
    func observe<O: ObservableObject>(_ observable: O,
                                      receive: @escaping (O.Message, AnyAuthor) -> Void)
    {
        let messenger = observable.messenger
        let connection = messenger.connect(receiver, receive: receive)
        receiver.retain(connection)
    }
    
    /**
     Receive the ``ObservableObject``'s future ``ObservableObject/Message``s
     */
    func observe<O: ObservableObject>(_ observable: O,
                                      receive: @escaping (O.Message) -> Void)
    {
        let messenger = observable.messenger
        let connection = messenger.connect(receiver, receive: receive)
        receiver.retain(connection)
    }
    
    /**
     End all the ``Observer``'s observations of this particular observed ``ObservableObject``
     
     Note that one ``Observer`` can have multiple distinct ongoing observations of the same ``ObservableObject``
     */
    func stopObserving<O: ObservableObject>(_ observable: O?)
    {
        observable.forSome
        {
            receiver.disconnectMessenger(with: $0.messenger.key)
        }
    }
    
    /**
     End all the ``Observer``'s observations of all its observed ``ObservableObject``s
     */
    func stopObserving()
    {
        receiver.disconnectAllMessengers()
    }
}

/**
 An object that can observe multiple ``ObservableObject``s
 
 One `Observer` can have multiple distinct ongoing observations of the same ``ObservableObject``
 */
public protocol Observer: AnyObject
{
    /**
     Required for receiving ``ObservableObject/Message``s from observed ``ObservableObject``s
     
     The ``Observer`` just holds on to its `receiver` strongly, so the `receiver`'s lifetime is bound to the ``Observer``s lifetime.
     
     Be careful to keep the `Observer` alive as long as it's supposed to observe, because when it dies, all its observations end as well.
     
     And the other way around: Be careful to not leak an `Observer` into memory, because that would also leak all its ongoing observations, if the corresponding ``ObservableObject``s don't explicitly end them.
     */
    var receiver: Receiver { get }
}
