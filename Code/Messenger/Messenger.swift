import SwiftyToolz

extension Messenger: RegisteredMessenger
{
    func receiverWantsToBeRemoved(_ receiver: AnyReceiver)
    {
        receivers.remove(receiver)
    }
    
    var receiverKeys: Set<ReceiverKey> { receivers.keys }
}

public class Messenger<Message>
{
    // MARK: - Life Cycle
    
    public init() {}
    deinit { registry.unregister(self) }
    
    // MARK: - Manage Receivers
    
    internal func send(_ message: Message)
    {
        receivers.receive(message)
    }
    
    internal func has(receiver: AnyReceiver) -> Bool
    {
        receivers.contains(receiver)
    }
    
    internal func add(_ receiver: AnyReceiver,
                      receive: @escaping (Message) -> Void)
    {
        receivers.add(receiver, receive: receive)
        registry.registerThat(receiver, isConnectedTo: self)
    }
    
    internal func remove(_ receiver: AnyReceiver)
    {
        receivers.remove(receiver)
        registry.unregisterThat(receiver, isConnectedTo: self)
    }
    
    private let receivers = ReceiverPool<Message>()
    private var registry: ConnectionRegistry { .shared }
}
