public extension ObservationTransformer
{
    func unwrap<Unwrapped>(receiveUnwrapped: @escaping (Unwrapped, AnyAuthor) -> Void)
        where Transformed == Unwrapped?
    {
        startObservation
        {
            message, author in
            
            if let unwrapped = message { receiveUnwrapped(unwrapped, author) }
        }
    }
    
    func unwrap<Unwrapped>(receiveUnwrapped: @escaping (Unwrapped) -> Void)
        where Transformed == Unwrapped?
    {
        startObservation
        {
            message, _ in
            
            if let unwrapped = message { receiveUnwrapped(unwrapped) }
        }
    }
    
    func unwrap<Unwrapped>() -> ObservationTransformer<Unwrapped>
        where Transformed == Unwrapped?
    {
        ObservationTransformer<Unwrapped>
        {
            receiveUnwrapped in
            
            self.startObservation
            {
                message, author in
                
                if let unwrapped = message { receiveUnwrapped(unwrapped, author) }
            }
        }
    }
}
