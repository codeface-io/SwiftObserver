public extension ObservationTransformer
{
    func new<Value>(receiveNew: @escaping (Value, AnyAuthor) -> Void)
        where Transformed == Update<Value>
    {
        map({ $0.new }, receiveMapped: receiveNew)
    }
    
    func new<Value>(receiveNew: @escaping (Value) -> Void)
        where Transformed == Update<Value>
    {
        map({ $0.new }, receiveMapped: receiveNew)
    }
    
    func new<Value>() -> ObservationTransformer<Value>
        where Transformed == Update<Value>
    {
        map { $0.new }
    }
}
