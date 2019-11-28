import SwiftyToolz

extension Messenger: RegisteredObservable
{
    func observerWantsToBeRemoved(_ observer: AnyObserver)
    {
        observerList.remove(observer)
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
        observerList.receive(message)
    }
    
    func add(_ observer: AnyObject,
             receive: @escaping (Message) -> Void)
    {
        observerList.add(observer, receive: receive)
        ObservationRegistry.shared.registerThat(observer, observes: self)
    }
    
    func remove(_ observer: AnyObject)
    {
        observerList.remove(observer)
        ObservationRegistry.shared.unregisterThat(observer, observes: self)
    }
    
    private let observerList = ObserverList<Message>()
}
