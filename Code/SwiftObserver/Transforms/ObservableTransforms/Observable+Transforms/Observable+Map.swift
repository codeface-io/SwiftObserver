public extension ObservableObject
{
    func map<Mapped>(_ map: @escaping (Message) -> Mapped) -> Mapper<Self, Mapped>
    {
        Mapper(self, map)
    }
}
