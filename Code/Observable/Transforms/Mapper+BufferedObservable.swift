extension Mapper: BufferedObservable where O: BufferedObservable
{
    public var latestMessage: Mapped
    {
        map(observable.latestMessage)
    }
}
