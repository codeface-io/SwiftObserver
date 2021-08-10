public extension ObservableCache
{
    func send() { send(latestMessage) }
}

public protocol ObservableCache: ObservableObject
{
    var latestMessage: Message { get }
}
