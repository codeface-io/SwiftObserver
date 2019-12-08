import SwiftyToolz

// MARK: - Connection

class Connection: ConnectionInterface
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
        receiver?.release(self)
    }
    
    let receiverKey: ReceiverKey
    weak var receiver: ReceiverInterface?
    
    func unregisterFromMessenger()
    {
        messenger?.unregister(self)
    }
    
    let messengerKey: MessengerKey
    weak var messenger: MessengerInterface?
}

// MARK: - Receiver Interface

extension ReceiverInterface
{
    var key: ReceiverKey { ReceiverKey(self) }
}

protocol ReceiverInterface: class
{
    func release(_ connection: ConnectionInterface)
}

// MARK: - Messenger Interface

extension MessengerInterface
{
    var key: MessengerKey { MessengerKey(self) }
}

protocol MessengerInterface: class
{
    func unregister(_ connection: ConnectionInterface)
}

// MARK: - Connection Interface

protocol ConnectionInterface: class
{
    var receiverKey: ReceiverKey { get }
    var messengerKey: MessengerKey { get }
}

typealias ReceiverKey = ObjectIdentifier
typealias MessengerKey = ObjectIdentifier
