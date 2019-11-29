import SwiftyToolz

class ConnectionRegistry
{
    static let shared = ConnectionRegistry()
    private init() {}
    
    func registerThat(_ receiver: AnyReceiver,
                      isConnectedTo messenger: RegisteredMessenger)
    {
        let connection = Connection(receiver, messenger)
        
        if connections[key(receiver)] == nil
        {
            connections[key(receiver)] = [RegisteredMessenger.Key : Connection]()
        }
        
        connections[key(receiver)]?[messenger.key] = connection
        
        if messengers[messenger.key]?.messenger !== messenger
        {
            messengers[messenger.key] = WeakMessenger(messenger)
        }
    }
    
    func unregisterThat(_ receiver: AnyReceiver,
                        isConnectedTo messenger: RegisteredMessenger)
    {
        connections[key(receiver)]?[messenger.key] = nil
        
        if connections[key(receiver)]?.isEmpty ?? false
        {
            connections[key(receiver)] = nil
        }
        
        if messenger.receiverKeys.isEmpty
        {
            messengers[messenger.key] = nil
        }
    }
   
    func unregister(_ receiver: AnyReceiver)
    {
        connections[key(receiver)]?.values.forEach
        {
            connection in
            
            guard let messenger = connection.messenger else { return }
            
            messenger.receiverWantsToBeRemoved(receiver)
            
            if messenger.receiverKeys.isEmpty
            {
                messengers[messenger.key] = nil
            }
        }
        
        connections[key(receiver)] = nil
    }
    
    func unregister(_ messenger: RegisteredMessenger)
    {
        let messengerKey = messenger.key
        
        messengers[messengerKey]?.messenger?.receiverKeys.forEach
        {
            receiverKey in
            
            connections[receiverKey]?[messengerKey] = nil
            
            if connections[receiverKey]?.isEmpty ?? false
            {
                connections[receiverKey] = nil
            }
        }
        
        messengers[messengerKey] = nil
    }
    
    private var connections = [ReceiverKey : [RegisteredMessenger.Key : Connection]]()
    private var messengers = [RegisteredMessenger.Key : WeakMessenger]()
    
    private class Connection
    {
        init(_ receiver: AnyReceiver, _ messenger: RegisteredMessenger)
        {
            self.receiver = receiver
            self.messenger = messenger
        }
        
        // TODO: do we even need the receiver here? if not we can remove Connection and just use WeakMessenger ...
        private weak var receiver: AnyReceiver?
        weak var messenger: RegisteredMessenger?
    }
}

struct WeakMessenger
{
    init(_ messenger: RegisteredMessenger)
    {
        self.messenger = messenger
    }
    
    weak var messenger: RegisteredMessenger?
}

extension RegisteredMessenger
{
    var key: Key { Key(self) }
}

protocol RegisteredMessenger: class
{
    typealias Key = ObjectIdentifier
    func receiverWantsToBeRemoved(_ receiver: AnyReceiver)
    var receiverKeys: Set<ReceiverKey> { get }
}
