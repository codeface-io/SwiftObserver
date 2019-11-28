import SwiftyToolz

extension Messenger: RegisteredObservable
{
    func observerWantsToBeRemoved(_ observer: AnyObserver)
    {
        receivers.remove(observer)
    }
}

public class Messenger<Message>
{
    // MARK: - Life Cycle
    
    public init() {}
    
    deinit { ObservationRegistry.shared.unregister(observable: self) }
    
    // MARK: - Manage Receivers
    
    func send(_ message: Message)
    {
        receivers.receive(message)
    }
    
    func add(_ receiver: AnyObject,
             receive: @escaping (Message) -> Void)
    {
        receivers.add(receiver, receive: receive)
        ObservationRegistry.shared.registerThat(receiver, observes: self)
    }
    
    func remove(_ receiver: AnyObject)
    {
        receivers.remove(receiver)
        ObservationRegistry.shared.unregisterThat(receiver, observes: self)
    }
    
    private let receivers = ReceiverPool<Message>()
}
