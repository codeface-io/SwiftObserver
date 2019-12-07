public extension ObservationStarter where Message: Equatable
{
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
    
    func select(_ message: Message) -> ObservationStarter<Void>
    {
        filter({ $0 == message }).map { _ in }
    }
}
