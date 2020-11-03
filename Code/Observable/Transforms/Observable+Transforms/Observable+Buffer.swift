public extension Observable
{
    func buffer() -> Buffer<Self>
    {
        Buffer(self)
    }
}
