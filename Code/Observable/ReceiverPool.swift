import SwiftyToolz

class ReceiverPool<Message>
{
    init(messenger: MessengerInterface)
    {
        self.messenger = messenger
    }
    
    deinit
    {
        receiverReferences.values.forEach { $0.connection?.releaseFromReceiver() }
    }
    
    func receive(_ message: Message, from author: AnyAuthor)
    {
        receiverReferences.values.forEach
        {
            $0.receive(message, from: author)
        }
    }
    
    func contains(_ receiver: ReceiverInterface) -> Bool
    {
        receiverReferences[receiver.key]?.connection?.receiver === receiver
    }
    
    func add(_ receiver: ReceiverInterface,
             receive: @escaping (Message, AnyAuthor) -> Void) -> Connection
    {
        if let existingReceiverReference = receiverReferences[receiver.key]
        {
            guard let connection = existingReceiverReference.connection else
            {
                log(error: "Connection is dead, meaning its owning receiver is dead, which shouldn't happen since receivers, before they die, unregister their connections from the respective messengers.")
                
                existingReceiverReference.messageHandlers = [receive]
                let connection = Connection(messenger: messenger, receiver: receiver)
                existingReceiverReference.connection = connection
                return connection
            }

            existingReceiverReference.messageHandlers += receive
            return connection
        }
        else
        {
            let connection = Connection(messenger: messenger, receiver: receiver)
            let reference = ReceiverReference(connection: connection, receive: receive)
            receiverReferences[receiver.key] = reference
            return connection
        }
    }
    
    func releaseConnectionFromReceiver(with receiverKey: ReceiverKey)
    {
        receiverReferences[receiverKey]?.connection?.releaseFromReceiver()
    }
    
    func releaseAllConnectionsFromReceivers()
    {
        receiverReferences.values.forEach
        {
            $0.connection?.releaseFromReceiver()
        }
    }
    
    func removeReceiver(with receiverKey: ReceiverKey)
    {
        receiverReferences[receiverKey] = nil
    }
    
    func removeAll()
    {
        receiverReferences.removeAll()
    }
    
    private var receiverReferences = [ReceiverKey : ReceiverReference]()
    
    private class ReceiverReference
    {
        init(connection: Connection, receive: @escaping (Message, AnyAuthor) -> Void)
        {
            self.connection = connection
            self.messageHandlers = [receive]
        }
        
        func receive(_ message: Message, from author: AnyAuthor)
        {
            guard let connection = connection else
            {
                return log(error: "Tried to send message via dead connection.")
            }
            
            guard connection.receiver != nil else
            {
                return log(error: "Tried to send message to dead receiver.")
            }
            
            messageHandlers.forEach
            {
                receive in receive(message, author)
            }
        }
        
        weak var connection: Connection?
        var messageHandlers: [(Message, _ from: AnyAuthor) -> Void]
    }
    
    private let messenger: MessengerInterface
}
