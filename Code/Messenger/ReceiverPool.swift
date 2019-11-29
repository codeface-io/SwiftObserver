 import SwiftyToolz
 
 class ReceiverPool<Message>
 {
    // MARK: - Forward Messages to Receivers
    
    func receive(_ message: Message)
    {
        messageQueue.append(message)
        
        if messageQueue.count > 1 { return }
        
        while let message = messageQueue.first
        {
            for (receiverKey, receiverReference) in receivers
            {
                guard receiverReference.receiver != nil else
                {
                    log(warning: "Tried so send message to dead receiver. Will remove receiver.")
                    receivers[receiverKey] = nil
                    continue
                }
                
                receiverReference.receive(message)
            }
            
            messageQueue.removeFirst()
        }
    }
    
    private var messageQueue = [Message]()
    
    // MARK: - Manage Receivers
    
    func add(_ receiver: AnyReceiver, receive: @escaping (Message) -> Void)
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
        init(receiver: AnyReceiver, receive: @escaping (Message) -> Void)
        {
            self.receiver = receiver
            self.receive = receive
        }
        
        weak var receiver: AnyReceiver?
        let receive: (Message) -> Void
    }
}
