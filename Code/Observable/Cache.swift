public extension Cache
{
    func send() { send(latestMessage) }
}

public protocol Cache: Observable
{
    var latestMessage: Message { get }
}
