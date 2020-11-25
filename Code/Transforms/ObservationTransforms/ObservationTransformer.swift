public struct ObservationTransformer<Transformed>
{
    public func receive(_ receive: @escaping (Transformed, AnyAuthor) -> Void)
    {
        startObservation(receive)
    }
    
    public func receive(_ receive: @escaping (Transformed) -> Void)
    {
        startObservation
        {
            message, _ in receive(message)
        }
    }
    
    internal let startObservation: (@escaping (Transformed, AnyAuthor) -> Void) -> Void
}
