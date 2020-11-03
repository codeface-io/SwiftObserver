extension Mapper: BufferedObservable where O: BufferedObservable
{
    // FIXME: this doesn't really do it in case someone calls send on the mapper directly. the mapper would need to be a Messenger and track all the sent messages and authors like Buffer does. but then all mappers would be buffered and have that redundant message store .... so better document this possibly unexpected behaviour of the "buffered" Mapper.
    public var latestMessage: Mapped
    {
        map(observable.latestMessage)
    }
}
