public extension Observable
{
    func filter(_ keep: @escaping (Message) -> Bool) -> Filter<Self>
    {
        Filter(self, keep)
    }
}
