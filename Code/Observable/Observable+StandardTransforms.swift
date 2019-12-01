public extension Observable where Message: Equatable
{
    func select(_ message: Message) -> Mapper<Filter<Self>, Void>
    {
        Mapper(Filter(self, keep: { $0 == message })) { _ in }
    }
}

public extension Observable
{
    func new<Value>() -> Mapper<Self, Value>
        where Message == Change<Value>
    {
        Mapper(self) { $0.new }
    }
    
    func filter(_ keep: @escaping (Message) -> Bool) -> Filter<Self>
    {
        Filter(self, keep: keep)
    }
    
    func unwrap<Wrapped>(_ default: Wrapped) -> Mapper<Self, Wrapped>
        where Message == Wrapped?
    {
        Mapper(self) { $0 ?? `default` }
    }
    
    func unwrap<Wrapped>() -> Unwrapper<Self, Wrapped>
        where Message == Wrapped?
    {
        Unwrapper(self)
    }
    
    func map<Mapped>(map: @escaping (Message) -> Mapped) -> Mapper<Self, Mapped>
    {
        Mapper(self, map: map)
    }
}
