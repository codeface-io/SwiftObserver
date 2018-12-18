import SwiftyToolz

public typealias Var = Variable

public class Variable<Value: Equatable & Codable>: ObservableObject<Change<Value>>, Codable
{
    // MARK: - Initialization
    
    public convenience init<Wrapped>() where Value == Optional<Wrapped>
    {
        self.init(nil)
    }
    
    public init(_ value: Value)
    {
        storedValue = value
        
        super.init()
    }
    
    // MARK: - Value Access

    public override var latestMessage: Change<Value>
    {
        return Change(value, value)
    }
    
    public var value: Value
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
