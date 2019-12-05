public extension Observable where Message: Equatable
{
    func select(_ message: Message) -> Mapper<Filter<Self>, Void>
    {
        Mapper(Filter(self, { $0 == message })) { _ in }
    }
}

public extension Observable
{
    func new<Value>() -> Mapper<Self, Value>
        where Message == Update<Value>
    {
        Mapper(self) { $0.new }
    }
    
    func filter(_ keep: @escaping (Message) -> Bool) -> Filter<Self>
    {
        Filter(self, keep)
    }
    
    func unwrap<Wrapped>(_ defaultMessage: Wrapped) -> Mapper<Self, Wrapped>
        where Message == Wrapped?
    {
        Mapper(self) { $0 ?? defaultMessage }
    }
    
    func unwrap<Wrapped>() -> Unwrapper<Self, Wrapped>
        where Message == Wrapped?
    {
        Unwrapper(self)
    }
    
    func map<Mapped>(_ map: @escaping (Message) -> Mapped) -> Mapper<Self, Mapped>
    {
        Mapper(self, map)
    }
}
