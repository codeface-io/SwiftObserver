public extension ObservationTransform
{
    func unwrap<Unwrapped>(receiveUnwrapped: @escaping (Unwrapped, AnyAuthor) -> Void)
        where Message == Unwrapped?
    {
        startObservation
        {
            message, author in
            
            if let unwrapped = message { receiveUnwrapped(unwrapped, author) }
        }
    }
    
    func unwrap<Unwrapped>(receiveUnwrapped: @escaping (Unwrapped) -> Void)
        where Message == Unwrapped?
    {
        startObservation
        {
            message, _ in
            
            if let unwrapped = message { receiveUnwrapped(unwrapped) }
        }
    }
    
    func unwrap<Unwrapped>() -> ObservationTransform<Unwrapped> where Message == Unwrapped?
    {
        ObservationTransform<Unwrapped>
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
