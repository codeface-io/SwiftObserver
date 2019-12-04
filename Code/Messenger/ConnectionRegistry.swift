import SwiftyToolz

class ConnectionRegistry
{
    static let shared = ConnectionRegistry()
    private init() {}
    
    // MARK: - The Purpose of this Registry: Disconnecting a Receiver from ALL Messengers
    
    func disconnectFromMessengers(_ receiver: AnyReceiver)
    {
        let receiverKey = key(receiver)
        
        keysOfConnectedMessengers[receiverKey]?.forEach
        {
            messengerKey in
            
            weakMessengers[messengerKey]?.messenger?.disconnect(receiver)
        }
    }
    
    // MARK: - Register / Unregister Connections
    
    func unregister(_ messenger: RegisteredMessenger)
    {
        let messengerKey = messenger.key
        
        messenger.receiverKeys.forEach
        {
            receiverKey in remove(messengerKey, for: receiverKey)
        }
        
        removeWeakMessenger(for: messengerKey)
    }
    
    func registerConnection(_ messenger: RegisteredMessenger,
                            _ receiver: AnyReceiver)
    {
        let messengerKey = messenger.key
        weakMessengers[messengerKey] = WeakMessenger(messenger)
        
        let receiverKey = key(receiver)
        var messengersOfReceiver = keysOfConnectedMessengers[receiverKey] ?? []
        messengersOfReceiver.insert(messengerKey)
        keysOfConnectedMessengers[receiverKey] = messengersOfReceiver
    }
    
    func unregisterConnection(_ messenger: RegisteredMessenger,
                              _ receiver: AnyReceiver)
    {
        remove(messenger.key, for: key(receiver))
        
        if messenger.receiverKeys.isEmpty
        {
            removeWeakMessenger(for: messenger.key)
        }
    }
    
    // MARK: - Hash Maps
    
    private func remove(_ messengerKey: RegisteredMessenger.Key,
                        for receiverKey: ReceiverKey)
    {
        guard var messengersOfReceiver = keysOfConnectedMessengers[receiverKey] else { return }
        messengersOfReceiver.remove(messengerKey)
        keysOfConnectedMessengers[receiverKey] = messengersOfReceiver.isEmpty ? nil : messengersOfReceiver
    }
    
    private var keysOfConnectedMessengers = [ReceiverKey : Set<RegisteredMessenger.Key>]()
    
    private func removeWeakMessenger(for messengerKey: RegisteredMessenger.Key)
    {
        weakMessengers[messengerKey] = nil
    }
    
    private var weakMessengers = [RegisteredMessenger.Key : WeakMessenger]()
    
    struct WeakMessenger
    {
        init(_ messenger: RegisteredMessenger) { self.messenger = messenger }
        
        weak var messenger: RegisteredMessenger?
    }
}

extension RegisteredMessenger
{
    var key: Key { Key(self) }
}

protocol RegisteredMessenger: class
{
    typealias Key = ObjectIdentifier
    func disconnect(_ receiver: AnyReceiver)
    var receiverKeys: Set<ReceiverKey> { get }
}
