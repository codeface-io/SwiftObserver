import SwiftyToolz

class ReceiverPool<Message>
{
    deinit
    {
        receiverReferences.values.forEach { $0.connection?.releaseFromReceiver() }
    }
    
    func receive(_ message: Message, from author: AnyAuthor)
    {
        receiverReferences.forEach
        {
            (receiverKey, receiverReference) in
            
            guard let connection = receiverReference.connection else
            {
                receiverReferences[receiverKey] = nil
                return log(error: "Tried to send message via dead connection.")
            }
            
            guard connection.receiver != nil else
            {
                receiverReferences[receiverKey] = nil
                return log(error: "Tried to send message to dead receiver.")
            }
            
            receiverReference.messageHandlers.forEach
            {
                receive in receive(message, author)
            }
        }
    }
    
    func contains(_ receiver: ReceiverInterface) -> Bool
    {
        receiverReferences[receiver.key]?.connection?.receiver === receiver
    }
    
    func connect(_ messenger: MessengerInterface,
                 to receiver: ReceiverInterface,
                 receive: @escaping (Message, AnyAuthor) -> Void) -> Connection
    {
        
        if let existingReceiverReference = receiverReferences[receiver.key]
        {
            existingReceiverReference.messageHandlers += receive
            
            if let connection = existingReceiverReference.connection
            {
                return connection
            }
            else
            {
                let connection = Connection(messenger: messenger, receiver: receiver)
                existingReceiverReference.connection = connection
                return connection
            }
        }
        else
        {
            let connection = Connection(messenger: messenger, receiver: receiver)
            let reference = ReceiverReference(connection: connection, receive: receive)
            receiverReferences[receiver.key] = reference
            return connection
        }
    }
    
    func removeConnection(with receiverKey: ReceiverKey)
    {
        receiverReferences[receiverKey] = nil
    }
    
    private var receiverReferences = [ReceiverKey : ReceiverReference]()
    
    private class ReceiverReference
    {
        init(connection: Connection, receive: @escaping (Message, AnyAuthor) -> Void)
        {
            self.connection = connection
            self.messageHandlers = [receive]
        }
        
        weak var connection: Connection?
        var messageHandlers: [(Message, _ from: AnyAuthor) -> Void]
    }
}
