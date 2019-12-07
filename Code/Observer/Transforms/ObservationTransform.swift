public struct ObservationTransform<Message>
{
    public func receive(receiveTransformedMessage: @escaping (Message, AnyAuthor) -> Void)
    {
        startObservation(receiveTransformedMessage)
    }
    
    public func receive(receiveTransformedMessage: @escaping (Message) -> Void)
    {
        startObservation
        {
            message, _ in receiveTransformedMessage(message)
        }
    }
    
    internal let startObservation: (@escaping (Message, AnyAuthor) -> Void) -> Void
}
