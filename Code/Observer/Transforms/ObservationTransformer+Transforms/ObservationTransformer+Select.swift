public extension ObservationTransformer where Transformed: Equatable
{
    func select(_ message: Transformed,
                receiveSelected: @escaping (AnyAuthor) -> Void)
    {
        filter({ $0 == message }) { _, author in receiveSelected(author) }
    }
    
    func select(_ message: Transformed,
                receiveSelected: @escaping () -> Void)
    {
        filter({ $0 == message }).map({ _ in }, receiveMapped: receiveSelected)
    }
    
    func select(_ message: Transformed) -> ObservationTransformer<Void>
    {
        filter({ $0 == message }).map { _ in }
    }
}
