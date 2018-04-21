public struct Update<Value>
{
    init(_ old: Value, _ new: Value)
    {
        self.old = old
        self.new = new
    }
    
    let old: Value
    let new: Value
}
