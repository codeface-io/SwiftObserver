import SwiftyToolz

extension Receiver: ReceiverInterface {}

public final class Receiver
{
    public init() {}
    
    deinit { connections.values.forEach { $0.removeFromMessenger() } }
    
    internal func closeConnection(for messengerKey: MessengerKey)
    {
        connections[messengerKey]?.removeFromMessenger()
        connections[messengerKey] = nil
    }
    
    internal func closeAllConnections()
    {
        connections.values.forEach { $0.removeFromMessenger() }
        connections.removeAll()
    }
    
    internal func retain(_ connection: Connection)
    {
        if connection.receiver !== self
        {
            log(error: "\(Self.self) will retain a connection that points to a different \(Self.self).")
        }
        
        connections[connection.messengerKey] = connection
    }
    
    internal func remove(_ connection: ConnectionInterface)
    {
        connections[connection.messengerKey] = nil
    }
    
    private var connections = [MessengerKey : Connection]()
}
