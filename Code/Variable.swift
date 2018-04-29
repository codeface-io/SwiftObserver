public typealias Var = Variable

public class Variable<Value: Equatable & Codable>: AbstractVariable<Value?>, Codable
{
    // MARK: Initialization
    
    public override init(_ value: Value? = nil)
    {
        super.init(nil)
        
        storedValue = value
    }
    
    // MARK: Codability
    
    public required init(from decoder: Decoder) throws
    {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        storedValue = try values.decode(Value.self, forKey: .storedValue)
        
        super.init(storedValue)
    }
    
    private enum CodingKeys: String, CodingKey { case storedValue }
    
    // MARK: Value
    
    public override var value: Value?
    {
        get { return storedValue }
        
        set
        {
            valueQueue.append(newValue)
            
            if valueQueue.count != 1 { return }
            
            while !valueQueue.isEmpty
            {
                storedValue = valueQueue.removeFirst()
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
                updateObservers(Update(oldValue, storedValue))
            }
        }
    }
}
