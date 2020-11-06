extension Mapper: Cache where O: Cache
{
    public var latestMessage: Mapped
    {
        map(origin.latestMessage)
    }
}
