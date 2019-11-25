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
        self.value = value
        super.init()
    }
    
    // MARK: - Value Access

    public var latestMessage: Change<Value>
    {
        Change(value, value)
    }
    
    // MARK: - Value
    
    private enum CodingKeys: String, CodingKey { case value = "storedValue" }
    
    public var value: Value
    {
        didSet
        {
            if oldValue != value
            {
                send(Change(oldValue, value))
            }
        }
    }
}
