public extension ObservationTransformer
{
    func unwrap<Unwrapped>(_ defaultMessage: Unwrapped,
                           receiveUnwrapped: @escaping (Unwrapped, AnyAuthor) -> Void)
        where Transformed == Unwrapped?
    {
        map({ $0 ?? defaultMessage }, receiveMapped: receiveUnwrapped)
    }
    
    func unwrap<Unwrapped>(_ defaultMessage: Unwrapped,
                           receiveUnwrapped: @escaping (Unwrapped) -> Void)
        where Transformed == Unwrapped?
    {
        map({ $0 ?? defaultMessage }, receiveMapped: receiveUnwrapped)
    }
    
    func unwrap<Unwrapped>(_ defaultMessage: Unwrapped) -> ObservationTransformer<Unwrapped>
        where Transformed == Unwrapped?
    {
        map { $0 ?? defaultMessage }
    }
}
