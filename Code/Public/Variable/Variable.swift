import SwiftyToolz

public typealias Var = Variable

public class Variable<Value: Equatable & Codable>: ObservableObject<Change<Value>>,
    BufferedObservable,
    Codable
{
    // MARK: - Initialization
    
    public convenience init<Wrapped>() where Value == Wrapped?
    {
        self.init(nil)
    }
    
    public init(_ value: Value)
    {
        storedValue = value
        
        super.init()
    }
    
    // MARK: - Value Access

    public var latestMessage: Change<Value>
    {
        Change(value, value)
    }
    
    public var value: Value
    {
        get { storedValue }
        
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
    
    private var valueQueue = [Value]()
    
    // MARK: Stored Value
    
    private enum CodingKeys: CodingKey { case storedValue }
    
    private var storedValue: Value
    {
        didSet
        {
            if oldValue != storedValue
            {
                send(Change(oldValue, storedValue))
            }
        }
    }
}
