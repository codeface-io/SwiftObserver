public extension Change where Value : Equatable
{
    var valueChanged: Bool { old != new }
}

public struct Change<Value>
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
