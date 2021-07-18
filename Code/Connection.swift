import SwiftyToolz

// MARK: - Connection

class Connection
{
    init(messenger: MessengerInterface, receiver: ReceiverInterface)
    {
        self.receiver = receiver
        self.receiverKey = receiver.key
        self.messenger = messenger
        self.messengerKey = messenger.key
    }
    
    func releaseFromReceiver()
    {
        receiver?.releaseConnection(with: messengerKey)
    }
    
    func unregisterFromMessenger()
    {
        messenger?.unregisterConnection(with: receiverKey)
    }
    
    let receiverKey: ReceiverKey
    weak var receiver: ReceiverInterface?
    
    let messengerKey: MessengerKey
    weak var messenger: MessengerInterface?
}

// MARK: - Receiver Interface

extension ReceiverInterface
{
    var key: ReceiverKey { ReceiverKey(self) }
}

protocol ReceiverInterface: AnyObject
{
    func releaseConnection(with messengerKey: MessengerKey)
}

// MARK: - Messenger Interface

extension MessengerInterface
{
    var key: MessengerKey { MessengerKey(self) }
}

protocol MessengerInterface: AnyObject
{
    func unregisterConnection(with receiverKey: ReceiverKey)
}

// MARK: - Keys

typealias ReceiverKey = ObjectIdentifier
typealias MessengerKey = ObjectIdentifier
