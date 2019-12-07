import SwiftyToolz

extension Messenger: MessengerInterface {}

public final class Messenger<Message>
{
    // MARK: - Life Cycle
    
    public init() {}
    
    deinit
    {
        registrations.values.forEach { $0.connection?.releaseFromReceiver() }
    }
    
    // MARK: - Send Messages to Connected Receivers
    
    internal func send(_ message: Message, author: AnyAuthor)
    {
        guard maintainsMessageOrder else
        {
            registrations.values.forEach { $0.receive(message, author) }
            return
        }
        
        messagesFromAuthors.append((message, author))

        if messagesFromAuthors.count > 1 { return }
        
        while let (message, author) = messagesFromAuthors.first
        {
            registrations.values.forEach { $0.receive(message, author) }
            messagesFromAuthors.removeFirst()
        }
    }
    
    private var messagesFromAuthors = [(Message, AnyAuthor)]()
    public var maintainsMessageOrder = true
    
    // MARK: - Connect Receivers
    
    internal func isConnected(to receiver: ReceiverInterface) -> Bool
    {
        registrations[receiver.key]?.connection?.receiver === receiver
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
        
        let registration = ConnectionRegistration(connection: connection, receive: receive)
        registrations[connection.receiverKey] = registration
    }

    // MARK: - Connections
    
    internal func unregister(_ connection: ConnectionInterface)
    {
        let receiverKey = connection.receiverKey
        
        guard let registeredConnection = registrations[receiverKey]?.connection else
        {
            return
        }
        
        guard registeredConnection === connection else
        {
            return log(error: "Tried to unregister a connection with an outdated reused receiver key. This can only happen if \(Receiver.self) is retained outside its owning Observer after the Observer has died. You're not supposed to do anything with the \(Receiver.self) object, let alone retain it.")
        }
        
        registrations[receiverKey] = nil
    }
    
    private var registrations = [ReceiverKey : ConnectionRegistration]()
    
    private class ConnectionRegistration
    {
        init(connection: Connection, receive: @escaping (Message, AnyAuthor) -> Void)
        {
            self.connection = connection
            self.receive = receive
        }
        
        weak var connection: Connection?
        let receive: (Message, _ from: AnyAuthor) -> Void
    }
}

public typealias AnyAuthor = AnyObject
