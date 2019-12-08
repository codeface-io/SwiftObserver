import SwiftyToolz

public typealias Var = Variable

public final class Variable<Value: Equatable & Codable>: Observable, Equatable, Codable
{
    // MARK: - Initialization
    
    public convenience init<Wrapped>() where Value == Wrapped?
    {
        self.init(nil)
    }
    
    public init(_ value: Value)
    {
        self.value = value
    }
    
    // MARK: - Equatable
    
    public static func == (lhs: Variable<Value>, rhs: Variable<Value>) -> Bool
    {
        lhs.value == rhs.value
    }
    
    // MARK: - Value
    
    private enum CodingKeys: String, CodingKey { case value = "storedValue" }
    
    public var value: Value
    {
        didSet
        {
            if oldValue != value
            {
                send(Update(oldValue, value))
            }
        }
    }
    
    // MARK: - Observable
    
    public let messenger = Messenger<Update<Value>>()
}
