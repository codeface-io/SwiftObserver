import SwiftyToolz

extension Var: Codable where Value: Codable {}

public typealias Var = Variable

/**
 An observable wrapper object that makes changes of its contained `Value` observable
 */
public final class Variable<Value: Equatable>: Messenger<Update<Value>>, Equatable
{
    // MARK: - Initialization
    
    public convenience init<Wrapped>() where Value == Wrapped?
    {
        self.init(nil)
    }
    
    public init(_ value: Value)
    {
        storedValue = value
    }
    
    // MARK: - Equatable
    
    /**
     Two `Variable`s count as equal when their ``value``s are equal
     */
    public static func == (lhs: Variable<Value>,
                           rhs: Variable<Value>) -> Bool
    {
        lhs.storedValue == rhs.storedValue
    }
    
    // MARK: - Value
    
    /**
     The actual stored `Value`. The `Variable` sends an ``Update`` when its `value` changes
     */
    public var value: Value
    {
        get { storedValue }
        set { set(newValue, as: self) }
    }
    
    /**
     Set ``value`` itentifying the author of the potentially triggered ``Update`` message
     */
    public func set(_ value: Value, as author: AnyAuthor)
    {
        let oldValue = storedValue
        
        if value != oldValue
        {
            storedValue = value
            send(Update(oldValue, value), from: author)
        }
    }
    
    private enum CodingKeys: String, CodingKey { case storedValue }
    
    private var storedValue: Value
}
