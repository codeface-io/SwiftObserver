import SwiftyToolz

extension Receiver: ReceiverInterface {}

public final class Receiver
{
    // MARK: - Life Cycle
    
    public init() {}
    
    deinit
    {
        connections.values.forEach { $0.unregisterFromMessenger() }
    }
    
    // MARK: - Manage Connections
    
    internal func disconnectMessenger(with messengerKey: MessengerKey)
    {
        connections[messengerKey]?.unregisterFromMessenger()
        connections[messengerKey] = nil
    }
    
    internal func disconnectAllMessengers()
    {
        connections.values.forEach { $0.unregisterFromMessenger() }
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
    
    // MARK: - ReceiverInterface
    
    internal func releaseConnection(with messengerKey: MessengerKey)
    {
        connections[messengerKey] = nil
    }
    
    // MARK: - Connections
    
    private var connections = [MessengerKey: Connection]()
}
