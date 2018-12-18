public struct Change<Value>
{
    public init<Wrapped>() where Value == Optional<Wrapped>
    {
        self.init(nil, nil)
    }
    
    public init(_ old: Value, _ new: Value)
    {
        self.old = old
        self.new = new
    }
    
    public let old: Value
    public let new: Value
}
