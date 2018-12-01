public typealias Var = Variable

public class Variable<Value: Equatable & Codable>: Observable, Codable
{
    // MARK: Life Cycle
    
    public init(_ value: Value? = nil)
    {
        storedValue = value
        ObservationService.register(observable: self)
    }
    
    deinit
    {
        removeObservers()
        ObservationService.unregister(observable: self)
    }
    
    // MARK: Observable
    
    public func add(_ observer: AnyObject,
                    filter: UpdateFilter? = nil,
                    receive: @escaping UpdateReceiver)
    {
        guard let filter = filter else
        {
            observerList.add(observer, receive: receive)
            return
        }
        
        observerList.add(observer) { if filter($0) { receive($0) } }
    }
    
    public func remove(_ observer: AnyObject)
    {
        observerList.remove(observer)
    }
    
    public func removeObservers()
    {
        observerList.removeAll()
    }
    
    public func removeDeadObservers()
    {
        observerList.removeNilObservers()
    }
    
    public func send()
    {
        send(latestUpdate)
    }
    
    public func send(_ update: Update<Value?>)
    {
        observerList.receive(latestUpdate)
    }
    
    private let observerList = ObserverList<Update<Value?>>()
    
    // MARK: Value Access

    public var latestUpdate: Update<Value?>
    {
        return Update(value, value)
    }
    
    public var value: Value?
    {
        get { return storedValue }
        
        set
        {
            valueQueue.append(newValue)
            
            if valueQueue.count > 1 { return }
            
            while let first = valueQueue.first
            {
                storedValue = first
                
                // remove value AFTER all handlers were called. do NOT write `storedValue = valueQueue.removeFirst()`
                valueQueue.removeFirst()
            }
        }
    }
    
    private var valueQueue = [Value?]()
    
    // MARK: Stored Value
    
    private enum CodingKeys: CodingKey { case storedValue }
    
    private var storedValue: Value?
    {
        didSet
        {
            if oldValue != storedValue
            {
                send(Update(oldValue, storedValue))
            }
        }
    }
}
