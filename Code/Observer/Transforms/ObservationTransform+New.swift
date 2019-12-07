public extension ObservationTransform
{
    func new<Value>(receiveNew: @escaping (Value, AnyAuthor) -> Void)
        where Message == Update<Value>
    {
        map({ $0.new }, receiveMapped: receiveNew)
    }
    
    func new<Value>(receiveNew: @escaping (Value) -> Void)
        where Message == Update<Value>
    {
        map({ $0.new }, receiveMapped: receiveNew)
    }
    
    func new<Value>() -> ObservationTransform<Value>
        where Message == Update<Value>
    {
        map { $0.new }
    }
}
