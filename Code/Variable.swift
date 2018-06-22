// MARK: - Number Operators

infix operator +=: AssignmentPrecedence

public func +=<Number: Numeric>(variable: Var<Number>?, addition: Number)
{
    variable?.value = variable?.value ?? 0 + addition
}

infix operator -=: AssignmentPrecedence

public func -=<Number: Numeric>(variable: Var<Number>?, addition: Number)
{
    variable?.value = variable?.value ?? 0 - addition
}

// MARK: - Assignment Operator

infix operator <-: AssignmentPrecedence

public func <-<Value>(variable: Var<Value>?, value: Value?)
{
    variable?.value = value
}

// MARK: -

public typealias Var = Variable

public class Variable<Value: Equatable & Codable>: Observable, Codable
{
    // MARK: Life Cycle
    
    public init(_ value: Value? = nil) { storedValue = value }
    
    deinit { removeObservers() }
    
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
