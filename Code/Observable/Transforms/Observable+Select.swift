public extension Observable where Message: Equatable
{
    func select(_ message: Message) -> Mapper<Filter<Self>, Void>
    {
        Mapper(Filter(self, { $0 == message })) { _ in }
    }
}
