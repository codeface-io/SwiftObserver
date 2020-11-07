public extension ObservableCache
{
    func send() { send(latestMessage) }
}

public protocol ObservableCache: Observable
{
    var latestMessage: Message { get }
}
