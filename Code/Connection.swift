import SwiftyToolz

class Connection: ConnectionInterface
{
    init(messenger: MessengerInterface, receiver: AnyReceiver)
    {
        self.receiver = receiver
        self.receiverKey = ReceiverKey(receiver)
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
    weak var receiver: AnyReceiver?
    
    let messengerKey: MessengerKey
    private weak var messenger: MessengerInterface?
}

extension MessengerInterface
{
    var key: MessengerKey { MessengerKey(self) }
}

typealias MessengerKey = ObjectIdentifier

protocol MessengerInterface: class
{
    func remove(_ connection: ConnectionInterface, for receiverKey: ReceiverKey)
}

protocol ConnectionInterface: class {}
typealias ReceiverKey = ObjectIdentifier
