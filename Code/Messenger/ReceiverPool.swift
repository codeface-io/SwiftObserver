 import SwiftyToolz
 
 class ReceiverPool<Message>
 {
    // MARK: - Forward Messages to Receivers
    
    func receive(_ message: Message, from sender: AnySender)
    {
        messagesFromSenders.append((message, sender))
        
        if messagesFromSenders.count > 1 { return }
        
        while let (message, sender) = messagesFromSenders.first
        {
            for (receiverKey, receiverReference) in receivers
            {
                guard receiverReference.receiver != nil else
                {
                    log(warning: "Tried so send message to dead receiver. Will remove receiver.")
                    receivers[receiverKey] = nil
                    continue
                }
                
                receiverReference.receive(message, sender)
            }
            
            messagesFromSenders.removeFirst()
        }
    }
    
    private var messagesFromSenders = [(Message, AnySender)]()
    
    // MARK: - Manage Receivers
    
    func contains(_ receiver: AnyReceiver) -> Bool
    {
        receivers[key(receiver)]?.receiver === receiver
    }
    
    func add(_ receiver: AnyReceiver, receive: @escaping (Message, AnySender) -> Void)
    {
        receivers[key(receiver)] = ReceiverReference(receiver: receiver, receive: receive)
    }
    
    func remove(_ receiver: AnyReceiver)
    {
        receivers[key(receiver)] = nil
    }
    
    // MARK: - Receivers
    
    var isEmpty: Bool { receivers.isEmpty }
    var keys: Set<ReceiverKey> { Set(receivers.keys) }
    
    private var receivers = [ReceiverKey : ReceiverReference]()
    
    private class ReceiverReference
    {
        init(receiver: AnyReceiver, receive: @escaping (Message, AnySender) -> Void)
        {
            self.receiver = receiver
            self.receive = receive
        }
        
        weak var receiver: AnyReceiver?
        let receive: (Message, _ from: AnySender) -> Void
    }
}

func key(_ receiver: AnyReceiver) -> ReceiverKey { ReceiverKey(receiver) }
typealias ReceiverKey = ObjectIdentifier
public typealias AnyReceiver = AnyObject
 
public typealias AnySender = AnyObject
