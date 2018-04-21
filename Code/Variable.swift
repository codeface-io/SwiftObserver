public typealias Var = Variable

public class Variable<Value: Equatable & Codable>: AbstractVariable<Value?>, Codable
{
    public override init(_ value: Value? = nil)
    {
        super.init(nil)
        
        storedValue = value
        
        print("VAR INIT \(String(describing: value))")
    }
    
    deinit
    {
        print("VAR DEINIT \(String(describing: value))")
    }
    
    public required init(from decoder: Decoder) throws
    {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        storedValue = try values.decode(Value.self, forKey: .storedValue)
        
        super.init(storedValue)
    }
    
    public override var value: Value?
    {
        get { return storedValue }
        set { storedValue = newValue }
    }
    
    public enum CodingKeys: String, CodingKey { case storedValue }
    
    public var storedValue: Value?
    {
        didSet
        {
            if oldValue != storedValue
            {
                updateObservers(Update(oldValue, storedValue))
            }
        }
    }
}
