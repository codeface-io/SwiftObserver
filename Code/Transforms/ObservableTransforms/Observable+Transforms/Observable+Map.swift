public extension Observable
{
    func map<Mapped>(_ map: @escaping (Message) -> Mapped) -> Mapper<Self, Mapped>
    {
        Mapper(self, map)
    }
}
