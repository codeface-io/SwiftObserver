public extension ObservationTransform
{
    // MARK: - Mapping
    
    func map<Mapped>(_ map: @escaping (Message) -> Mapped,
                     receiveMapped: @escaping (Mapped, AnyAuthor) -> Void)
    {
        startObservation
        {
            message, author in
            
            receiveMapped(map(message), author)
        }
    }
    
    func map<Mapped>(_ map: @escaping (Message) -> Mapped,
                     receiveMapped: @escaping (Mapped) -> Void)
    {
        startObservation
        {
            message, _ in
            
            receiveMapped(map(message))
        }
    }
    
    func map<Mapped>(_ map: @escaping (Message) -> Mapped) -> ObservationTransform<Mapped>
    {
        ObservationTransform<Mapped>
        {
            receiveMapped in

            self.startObservation
            {
                message, author in
                
                receiveMapped(map(message), author)
            }
        }
    }
    
    // MARK: - Unwrapping
    
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
    
    // MARK: - Filtering
    
    func filter(_ keep: @escaping (Message) -> Bool,
                receiveFiltered: @escaping (Message, AnyAuthor) -> Void)
    {
        startObservation
        {
            message, author in

            if keep(message) { receiveFiltered(message, author) }
        }
    }
    
    func filter(_ keep: @escaping (Message) -> Bool,
                receiveFiltered: @escaping (Message) -> Void)
    {
        startObservation
        {
            message, _ in

            if keep(message) { receiveFiltered(message) }
        }
    }
    
    func filter(_ keep: @escaping (Message) -> Bool) -> ObservationTransform<Message>
    {
        ObservationTransform
        {
            receiveFiltered in

            self.startObservation
            {
                message, author in
                
                if keep(message) { receiveFiltered(message, author) }
            }
        }
    }
}

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
    
    let startObservation: (@escaping (Message, AnyAuthor) -> Void) -> Void
}
