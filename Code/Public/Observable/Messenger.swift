import SwiftyToolz

extension Messenger: RegisteredMessenger
{
    func receiverWantsToBeRemoved(_ receiver: AnyObject)
    {
        receivers.remove(receiver)
    }
}

public class Messenger<Message>
{
    // MARK: - Life Cycle
    
    public init() {}
    
    deinit { ObservationRegistry.shared.unregister(messenger: self) }
    
    // MARK: - Manage Receivers
    
    internal func send(_ message: Message)
    {
        receivers.receive(message)
    }
    
    internal func add(_ receiver: AnyObject,
                      receive: @escaping (Message) -> Void)
    {
        receivers.add(receiver, receive: receive)
        ObservationRegistry.shared.registerThat(receiver, observes: self)
    }
    
    internal func remove(_ receiver: AnyObject)
    {
        receivers.remove(receiver)
        ObservationRegistry.shared.unregisterThat(receiver, observes: self)
    }
    
    private let receivers = ReceiverPool<Message>()
}
