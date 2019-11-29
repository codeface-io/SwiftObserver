import SwiftyToolz

extension Messenger: RegisteredMessenger
{
    func receiverWantsToBeRemoved(_ receiver: AnyReceiver)
    {
        receivers.remove(receiver)
    }
}

public class Messenger<Message>
{
    // MARK: - Life Cycle
    
    public init() {}
    
    deinit { ConnectionRegistry.shared.unregister(self) }
    
    // MARK: - Manage Receivers
    
    internal func send(_ message: Message)
    {
        receivers.receive(message)
    }
    
    internal func add(_ receiver: AnyReceiver,
                      receive: @escaping (Message) -> Void)
    {
        receivers.add(receiver, receive: receive)
        ConnectionRegistry.shared.registerThat(receiver, isConnectedTo: self)
    }
    
    internal func remove(_ receiver: AnyReceiver)
    {
        receivers.remove(receiver)
        ConnectionRegistry.shared.unregisterThat(receiver, isConnectedTo: self)
    }
    
    private let receivers = ReceiverPool<Message>()
}
