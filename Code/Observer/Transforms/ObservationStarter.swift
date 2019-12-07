public struct ObservationStarter<Message>
{
    public func receive(_ receive: @escaping (Message, AnyAuthor) -> Void)
    {
        startObservation(receive)
    }
    
    public func receive(_ receive: @escaping (Message) -> Void)
    {
        startObservation
        {
            message, _ in receive(message)
        }
    }
    
    internal let startObservation: (@escaping (Message, AnyAuthor) -> Void) -> Void
}
