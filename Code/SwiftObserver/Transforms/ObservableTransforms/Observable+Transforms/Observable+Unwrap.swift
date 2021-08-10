public extension ObservableObject
{
    func unwrap<Wrapped>() -> Unwrapper<Self, Wrapped>
        where Message == Wrapped?
    {
        Unwrapper(self)
    }
}
