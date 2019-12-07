import SwiftyToolz

extension Receiver: ReceiverInterface {}

public final class Receiver
{
    public init() {}
    
    deinit { closeAllConnections() }
    
    internal func retain(_ connection: Connection)
    {
        guard connection.receiver === self else
        {
            log(error: "Tried to make \(Self.self) retain a connection that points to a different \(Self.self).")
            return
        }
        
        connections[connection.messengerKey] = connection
    }
    
    internal func remove(_ connection: ConnectionInterface)
    {
        connections[connection.messengerKey] = nil
    }
    
    internal func closeConnection(for messengerKey: MessengerKey)
    {
        connections[messengerKey]?.close()
    }
    
    internal func closeAllConnections()
    {
        connections.values.forEach { $0.close() }
    }
    
    private var connections = [MessengerKey : Connection]()
}
