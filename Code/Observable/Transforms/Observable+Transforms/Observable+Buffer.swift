public extension Observable
{
    func buffer<Unwrapped>() -> BufferForOptionalMessage<Self, Unwrapped>
    {
        BufferForOptionalMessage(self)
    }

    func buffer<Unwrapped>() -> BufferForNonOptionalMessage<Self, Unwrapped>
    {
        BufferForNonOptionalMessage(self)
    }
}
