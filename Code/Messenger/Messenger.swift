import SwiftyToolz

public class Messenger<Message>: MessengerInterface
{
    // MARK: - Life Cycle
    
    public init() {}
    
    deinit
    {
        connections.values.forEach { $0.connection?.close() }
    }
    
    // MARK: - Send Messages to Connected Receivers
    
    internal func send(_ message: Message, author: AnyAuthor)
    {
        messagesFromAuthors.append((message, author))
        
        if messagesFromAuthors.count > 1 { return }
        
        while let (message, author) = messagesFromAuthors.first
        {
            for connectionReference in connections.values
            {
                connectionReference.receive(message, author)
            }
            
            messagesFromAuthors.removeFirst()
        }
    }
    
    private var messagesFromAuthors = [(Message, AnyAuthor)]()
    
    // MARK: - Connect Receivers
    
    internal func isConnected(_ receiver: AnyReceiver) -> Bool
    {
        connections[ReceiverKey(receiver)]?.connection?.receiver === receiver
    }
    
    internal func connect(_ receiver: AnyReceiver,
                          receive: @escaping (Message) -> Void) -> Connection
    {
        connect(receiver) { message, _ in receive(message) }
    }
    
    internal func connect(_ receiver: AnyReceiver,
                          receive: @escaping (Message, AnyAuthor) -> Void) -> Connection
    {
        let connection = Connection(messenger: self, receiver: receiver)
        connections[ReceiverKey(receiver)] = ConnectionReference(connection: connection,
                                                                 receive: receive)
        return connection
    }

    // MARK: - Connections
    
    internal func remove(_ connection: ConnectionInterface, for receiver: ReceiverKey)
    {
        guard let existingConnection = connections[receiver]?.connection else { return }
        
        guard existingConnection === connection else
        {
            return log(error: "Tried to remove a connection with an outdated reused receiver key. This can only happen if \(Connections.self) is retained outside its owning Observer after the Observer has died. You're not supposed to do anything with the \(Connections.self) object, let alone retain it.")
        }
        
        connections[receiver] = nil
    }
    
    private var connections = [ReceiverKey : ConnectionReference]()
    
    private class ConnectionReference
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

public typealias AnyReceiver = AnyObject
public typealias AnyAuthor = AnyObject
