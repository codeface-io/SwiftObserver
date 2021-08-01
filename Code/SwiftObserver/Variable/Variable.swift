import SwiftyToolz

extension Var: Codable where Value: Codable {}

public typealias Var = Variable

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
    
    public static func == (lhs: Variable<Value>,
                           rhs: Variable<Value>) -> Bool
    {
        lhs.storedValue == rhs.storedValue
    }
    
    // MARK: - Value
    
    public var value: Value
    {
        get { storedValue }
        set { set(newValue, as: self) }
    }
    
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
