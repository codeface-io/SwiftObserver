import SwiftyToolz

class Connection: ConnectionInterface
{
    init(messenger: MessengerInterface, receiver: ReceiverInterface)
    {
        self.receiver = receiver
        self.receiverKey = receiver.key
        self.messenger = messenger
        self.messengerKey = messenger.key
    }
    
    deinit { close() }
    
    func close()
    {
        messenger?.remove(self, for: receiverKey)
        didClose?(self)
    }
    
    var didClose: ((Connection) -> Void)?
    
    let receiverKey: ReceiverKey
    weak var receiver: ReceiverInterface?
    
    let messengerKey: MessengerKey
    private weak var messenger: MessengerInterface?
}

// MARK: - Messenger Interface

extension MessengerInterface
{
    var key: MessengerKey { MessengerKey(self) }
}

typealias MessengerKey = ObjectIdentifier

protocol MessengerInterface: class
{
    func remove(_ connection: ConnectionInterface, for connectionsKey: ReceiverKey)
}

protocol ConnectionInterface: class {}

// MARK: - Receiver Interface

extension ReceiverInterface
{
    var key: ReceiverKey { ReceiverKey(self) }
}

typealias ReceiverKey = ObjectIdentifier

public protocol ReceiverInterface: class {}
