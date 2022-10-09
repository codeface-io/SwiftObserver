import SwiftyToolz

extension Messenger: MessengerInterface {}

/**
 The simplest `ObservableObject` and the basis of every other `ObservableObject`
 
 `Messenger` doesn't send messages by itself, but anyone can send messages through it and use it for any type of message:
 
 ```swift
 let textMessenger = Messenger<String>()

 observer.observe(textMessenger) { textMessage in
     // respond to textMessage
 }

 textMessenger.send("my message")
 ```
 */
public class Messenger<Message>
{
    // MARK: - Life Cycle
    
    public init() {}
    
    // MARK: - Send Messages to Receivers
    
    internal func _send(_ message: Message, from author: AnyAuthor)
    {
        messagesFromAuthors += (message, author)

        if messagesFromAuthors.count > 1 { return }
        
        while let (message, author) = messagesFromAuthors.first
        {
            storedLatestAuthor = author
            receivers.receive(message, from: author)
            messagesFromAuthors.removeFirst()
        }
    }
    
    private var messagesFromAuthors = [(Message, AnyAuthor)]()
    
    internal var _latestAuthor: AnyAuthor { storedLatestAuthor ?? self }
    private weak var storedLatestAuthor: AnyAuthor?
    
    // MARK: - Manage Receivers
    
    internal func isConnected(to receiver: ReceiverInterface) -> Bool
    {
        receivers.contains(receiver)
    }
    
    internal func connect(_ receiver: ReceiverInterface,
                           receive: @escaping (Message) -> Void) -> Connection
    {
        connect(receiver) { message, _ in receive(message) }
    }
    
    internal func connect(_ receiver: ReceiverInterface,
                          receive: @escaping (Message, AnyAuthor) -> Void) -> Connection
    {
        receivers.add(receiver, for: self, receive: receive)
    }
    
    internal func disconnectReceiver(with receiverKey: ReceiverKey)
    {
        receivers.releaseConnectionFromReceiver(with: receiverKey)
        receivers.removeReceiver(with: receiverKey)
    }
    
    internal func disconnectAllReceivers()
    {
        receivers.releaseAllConnectionsFromReceivers()
        receivers.removeAll()
    }
    
    // MARK: - MessengerInterface
    
    internal func unregisterConnection(with receiverKey: ReceiverKey)
    {
        receivers.removeReceiver(with: receiverKey)
    }
    
    // MARK: - Receivers
    
    private let receivers = ReceiverPool<Message>()
}
