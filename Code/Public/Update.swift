public struct Update<Value>
{
    public init(_ old: Value, _ new: Value)
    {
        self.old = old
        self.new = new
    }
    
    public let old: Value
    public let new: Value
}
