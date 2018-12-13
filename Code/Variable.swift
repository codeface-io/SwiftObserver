import SwiftyToolz

public typealias Var = Variable

public class Variable<Value: Equatable & Codable>: ObservableObject<Update<Value?>>, Codable
{
    // MARK: - Initialization
    
    public init(_ value: Value? = nil,
                file: String = #file,
                line: Int = #line)
    {
        if isOptional(Value.self)
        {
            fatalError("SwiftObserver.Variable: Value types are not supposed to be optional. Type: \(String(describing: Value.self)), File: \(file), line \(line)")
        }
        
        storedValue = value
        
        super.init()
    }
    
    // MARK: - Value Access

    public override var latestUpdate: Update<Value?>
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
