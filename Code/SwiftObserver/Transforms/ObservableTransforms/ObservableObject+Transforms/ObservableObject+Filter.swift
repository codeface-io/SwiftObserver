public extension ObservableObject
{
    func filter(_ keep: @escaping (Message) -> Bool) -> Filter<Self>
    {
        Filter(self, keep)
    }
}
