extension Mapper: ObservableCache where O: ObservableCache
{
    public var latestMessage: Mapped
    {
        map(origin.latestMessage)
    }
}
