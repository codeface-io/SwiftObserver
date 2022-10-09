public extension ObservableCache
{
    /**
     Send the ``latestMessage`` to all ``Observer``s
     */
    func send() { send(latestMessage) }
}

/**
 An ``ObservableObject`` that can provide its last sent (or some analogous) ``ObservableObject/Message``
 
 `ObservableCache` has a function ``send()`` that sends ``latestMessage``.
 
 A typical `ObservableCache` derives its `latestMessage` from some form of state.
 
 ``Variable`` is the most prominent `ObservableCache` in SwiftObserver. Its ``latestMessage`` is an ``Update`` in which ``Update/old`` and ``Update/new`` both hold the current ``Variable/value``.
 */
public protocol ObservableCache: ObservableObject
{
    /**
     Typically the last sent ``ObservableObject/Message`` or one that indicates that "nothing has changed"
     */
    var latestMessage: Message { get }
}
