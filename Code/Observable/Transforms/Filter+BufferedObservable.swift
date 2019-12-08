extension Filter: BufferedObservable
    where O: BufferedObservable, O.Message == Optional<Any>
{
    public var latestMessage: O.Message
    {
        let latestSourceMessage = observable.latestMessage
        return keep(latestSourceMessage) ? latestSourceMessage : nil
    }
}
