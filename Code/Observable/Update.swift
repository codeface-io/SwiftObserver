extension Update: Equatable where Value : Equatable
{
    var isChange: Bool { old != new }
}

public struct Update<Value>
{
    public init<Wrapped>() where Value == Wrapped?
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
