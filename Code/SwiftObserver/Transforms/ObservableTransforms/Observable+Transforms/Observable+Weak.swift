public extension Observable
{
    func weak() -> Weak<Self>
    {
        Weak(self)
    }
}
