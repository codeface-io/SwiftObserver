public extension ObservableObject
{
    func weak() -> Weak<Self>
    {
        Weak(self)
    }
}
