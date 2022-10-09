extension Update: Equatable where Value : Equatable
{
    /**
     If `Value` is `Equatable`, this indicates whether the `Update` represents a value change
     */
    public var isChange: Bool { old != new }
}

/**
 Intended as a value update ``ObservableObject/Message`` and employed in that way by ``Variable``
 */
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
