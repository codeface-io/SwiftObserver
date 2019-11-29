import SwiftyToolz

class ConnectionRegistry
{
    static let shared = ConnectionRegistry()
    private init() {}
    
    func askRegisteredMessengersToRemove(_ receiver: AnyReceiver)
    {
        connectionsByReceiver[key(receiver)]?.values.forEach { connection in
            connection.messenger?.receiverWantsToBeRemoved(receiver)
        }
    }
    
    func unregister(_ receiver: AnyReceiver)
    {
        let receiverKey = key(receiver)
        
        connectionsByReceiver[receiverKey]?.keys.forEach { messengerKey in
            connectionsByMessenger[messengerKey]?[receiverKey] = nil
        }
        
        connectionsByReceiver[receiverKey] = nil
    }
    
    func unregister(_ messenger: RegisteredMessenger)
    {
        let messengerKey = messenger.key
        
        connectionsByMessenger[messengerKey]?.keys.forEach { receiverKey in
            connectionsByReceiver[receiverKey]?[messengerKey] = nil
        }
        
        connectionsByMessenger[messengerKey] = nil
    }
    
    func registerThat(_ receiver: AnyReceiver,
                      isConnectedTo messenger: RegisteredMessenger)
    {
        guard !isRegisteredThat(receiver, isConnectedTo: messenger) else { return }
        
        let connection = Connection(receiver, messenger)
        
        if connectionsByReceiver[key(receiver)] == nil
        {
            connectionsByReceiver[key(receiver)] = [RegisteredMessenger.Key : Connection]()
        }
        
        connectionsByReceiver[key(receiver)]?[messenger.key] = connection
        
        if connectionsByMessenger[messenger.key] == nil
        {
           connectionsByMessenger[messenger.key] = [ReceiverKey : Connection]()
        }

        connectionsByMessenger[messenger.key]?[key(receiver)] = connection
    }
    
    func unregisterThat(_ receiver: AnyReceiver,
                        isConnectedTo messenger: RegisteredMessenger)
    {
        guard isRegisteredThat(receiver, isConnectedTo: messenger) else { return }
        
        connectionsByReceiver[key(receiver)]?[messenger.key] = nil
        connectionsByMessenger[messenger.key]?[key(receiver)] = nil
    }
    
    private func isRegisteredThat(_ receiver: AnyReceiver,
                                  isConnectedTo messenger: RegisteredMessenger) -> Bool
    {
        guard let connection = connectionsByReceiver[key(receiver)]?[messenger.key] else
        {
            return false
        }
        
        return connection.receiver != nil && connection.messenger != nil
    }
    
    private var connectionsByReceiver = [ReceiverKey : [RegisteredMessenger.Key : Connection]]()
    
    // TODO: if we have the messenger, we don't need another dictionary for the receiver... ask the messenger via the RegisteredMessenger protocol instead
    private var connectionsByMessenger = [RegisteredMessenger.Key : [ReceiverKey : Connection]]()
    
    private class Connection
    {
        init(_ receiver: AnyReceiver, _ messenger: RegisteredMessenger)
        {
            self.receiver = receiver
            self.messenger = messenger
        }
        
        weak var receiver: AnyReceiver?
        weak var messenger: RegisteredMessenger?
    }
}


extension RegisteredMessenger
{
    var key: Key { Key(self) }
}

protocol RegisteredMessenger: AnyObject
{
    typealias Key = ObjectIdentifier
    func receiverWantsToBeRemoved(_ receiver: AnyReceiver)
}
