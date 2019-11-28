import SwiftyToolz

extension ObservableObject: RegisteredObservable
{
    func observerWantsToBeRemoved(_ observer: AnyObserver)
    {
        observerList.remove(observer)
    }
}

public class ObservableObject<Message>: Observable
{
    // MARK: - Life Cycle
    
    public init() {}
    
    deinit { ObservationRegistry.unregister(observable: self) }
   
    // MARK: - Observable
    
    public func add(_ observer: AnyObject,
                    receive: @escaping (Message) -> Void)
    {
        observerList.add(observer, receive: receive)
        ObservationRegistry.registerThat(observer, observes: self)
    }
    
    public func remove(_ observer: AnyObject)
    {
        observerList.remove(observer)
        ObservationRegistry.unregisterThat(observer, observes: self)
    }
    
    public func send(_ message: Message)
    {
        observerList.receive(message)
    }
    
    private let observerList = ObserverList<Message>()
}
