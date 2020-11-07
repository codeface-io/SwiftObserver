public extension ObservableCache
{
    func whenCached<Unwrapped>(_ receive: @escaping (Unwrapped) -> Void)
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
    
    func whenCached<Unwrapped>(_ receive: @escaping (Unwrapped, AnyAuthor) -> Void)
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
