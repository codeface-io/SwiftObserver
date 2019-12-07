public extension ObservationStarter
{
    func unwrap<Unwrapped>(_ defaultMessage: Unwrapped,
                           receiveUnwrapped: @escaping (Unwrapped, AnyAuthor) -> Void)
        where Message == Unwrapped?
    {
        map({ $0 ?? defaultMessage }, receiveMapped: receiveUnwrapped)
    }
    
    func unwrap<Unwrapped>(_ defaultMessage: Unwrapped,
                           receiveUnwrapped: @escaping (Unwrapped) -> Void)
        where Message == Unwrapped?
    {
        map({ $0 ?? defaultMessage }, receiveMapped: receiveUnwrapped)
    }
    
    func unwrap<Unwrapped>(_ defaultMessage: Unwrapped) -> ObservationStarter<Unwrapped>
        where Message == Unwrapped?
    {
        map { $0 ?? defaultMessage }
    }
}
