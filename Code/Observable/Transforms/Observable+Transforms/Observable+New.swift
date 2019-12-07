public extension Observable
{
    func new<Value>() -> Mapper<Self, Value>
        where Message == Update<Value>
    {
        Mapper(self) { $0.new }
    }
}
