public extension BufferedObservable
{
    func fill<Unwrapped>(_ unwrapped: Unwrapped)
        where Message == Unwrapped?
    {
        send(unwrapped)
    }
    
    func fill<Unwrapped>(_ unwrapped: Unwrapped, as author: AnyAuthor)
        where Message == Unwrapped?
    {
        send(unwrapped, from: author)
    }
    
    func whenFilled<Unwrapped>(_ receive: @escaping (Unwrapped) -> Void)
        where Message == Unwrapped?
    {
        if let message = latestMessage
        {
            receive(message)
        }
        else
        {
            let observer = FreeObserver()
            
            observer.observe(self).unwrap
            {
                observer.stopObserving()
                receive($0)
            }
        }
    }
    
    func whenFilled<Unwrapped>(_ receive: @escaping (Unwrapped, AnyAuthor) -> Void)
        where Message == Unwrapped?
    {
        if let message = latestMessage
        {
            receive(message, latestAuthor)
        }
        else
        {
            let observer = FreeObserver()
            
            observer.observe(self).unwrap
            {
                observer.stopObserving()
                receive($0, $1)
            }
        }
    }
}
