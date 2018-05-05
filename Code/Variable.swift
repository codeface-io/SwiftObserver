infix operator <-: AdditionPrecedence

@discardableResult
public func <-<Value>(variable: Var<Value>?,
                      value: Value?) -> Var<Value>?
{
    variable?.value = value
    return variable
}

public typealias Var = Variable

public class Variable<Value: Equatable & Codable>: Observable, Codable
{
    // MARK: Initialization
    
    public init(_ value: Value? = nil)
    {
        storedValue = value
    }
    
    // MARK: Send Update When Observation Starts
    
    public func add(_ observer: AnyObject,
                    _ receive: @escaping (UpdateType) -> Void)
    {
        ObservationService.add(observer, of: self)
        {
            guard let update = $0 as? UpdateType else
            {
                fatalError("Impossible error: could not cast update type received from observation center")
            }
            
            receive(update)
        }
        
        receive(latestUpdate)
    }
    
    // MARK: Codability
    
    private enum CodingKeys: String, CodingKey { case storedValue }
    
    // MARK: Value

    public var latestUpdate: Update<Value?>
    {
        let currentValue = value
        
        return Update(currentValue, currentValue)
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
