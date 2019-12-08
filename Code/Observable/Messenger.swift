import SwiftyToolz

extension Messenger: MessengerInterface {}

public final class Messenger<Message>
{
    // MARK: - Life Cycle
    
    public init() {}
    
    // MARK: - Send Messages to Receivers
    
    internal func send(_ message: Message, from author: AnyAuthor)
    {
        guard maintainsMessageOrder else
        {
            return receivers.receive(message, from: author)
        }
        
        messagesFromAuthors.append((message, author))

        if messagesFromAuthors.count > 1 { return }
        
        while let (message, author) = messagesFromAuthors.first
        {
            receivers.receive(message, from: author)
            messagesFromAuthors.removeFirst()
        }
    }
    
    private var messagesFromAuthors = [(Message, AnyAuthor)]()
    public var maintainsMessageOrder = true
    
    // MARK: - Manage Receivers
    
    internal func isConnected(to receiver: ReceiverInterface) -> Bool
    {
        receivers.contains(receiver)
    }
    
    internal func register(_ connection: Connection,
                           receive: @escaping (Message) -> Void)
    {
        register(connection) { message, _ in receive(message) }
    }
    
    internal func register(_ connection: Connection,
                           receive: @escaping (Message, AnyAuthor) -> Void)
    {
        if connection.messenger !== self
        {
            log(error: "\(Self.self) will register a connection that points to a different \(Self.self).")
        }
        
        receivers.add(connection, receive: receive)
    }
    
    internal func unregister(_ connection: ConnectionInterface)
    {
        receivers.remove(connection)
    }
    
    private let receivers = ReceiverPool<Message>()
}
