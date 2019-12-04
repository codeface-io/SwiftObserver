import SwiftyToolz

extension Messenger: RegisteredMessenger
{
    var receiverKeys: Set<ReceiverKey> { receivers.keys }
}

public class Messenger<Message>
{
    // MARK: - Life Cycle
    
    public init() {}
    deinit { connectionRegistry.unregister(self) }
    
    // MARK: - Manage Receivers
    
    internal func send(_ message: Message, author: AnyAuthor)
    {
        receivers.receive(message, from: author)
    }
    
    internal func isConnected(to receiver: AnyReceiver) -> Bool
    {
        receivers.contains(receiver)
    }
    
    internal func connect(_ receiver: AnyReceiver,
                          receive: @escaping (Message, AnyAuthor) -> Void)
    {
        receivers.add(receiver, receive: receive)
        connectionRegistry.registerConnection(self, receiver)
    }
    
    internal func disconnect(_ receiver: AnyReceiver)
    {
        receivers.remove(receiver)
        connectionRegistry.unregisterConnection(self, receiver)
    }
    
    private let receivers = ReceiverPool<Message>()
    private var connectionRegistry: ConnectionRegistry { .shared }
}
