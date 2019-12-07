public extension ObservationStarter
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
    
    func unwrap<Unwrapped>() -> ObservationStarter<Unwrapped> where Message == Unwrapped?
    {
        ObservationStarter<Unwrapped>
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
