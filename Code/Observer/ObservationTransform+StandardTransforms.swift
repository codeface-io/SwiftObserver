public extension ObservationTransform
{
    // MARK: - Mapping Onto New Value
    
    func new<Value>(receiveNew: @escaping (Value, AnyAuthor) -> Void)
        where Message == Update<Value>
    {
        map({ $0.new }, receiveMapped: receiveNew)
    }
    
    func new<Value>(receiveNew: @escaping (Value) -> Void)
        where Message == Update<Value>
    {
        map({ $0.new }, receiveMapped: receiveNew)
    }
    
    func new<Value>() -> ObservationTransform<Value>
        where Message == Update<Value>
    {
        map { $0.new }
    }
    
    // MARK: - Unwrapping with Default
    
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
    
    func unwrap<Unwrapped>(_ defaultMessage: Unwrapped) -> ObservationTransform<Unwrapped>
        where Message == Unwrapped?
    {
        map { $0 ?? defaultMessage }
    }
}

public extension ObservationTransform where Message: Equatable
{
    // MARK: - Selecting
    
    func select(_ message: Message,
                receiveSelected: @escaping (AnyAuthor) -> Void)
    {
        filter({ $0 == message }) { _, author in receiveSelected(author) }
    }
    
    func select(_ message: Message,
                receiveSelected: @escaping () -> Void)
    {
        filter({ $0 == message }).map({ _ in }, receiveMapped: receiveSelected)
    }
    
    func select(_ message: Message) -> ObservationTransform<Void>
    {
        filter({ $0 == message }).map { _ in }
    }
}
