import SwiftyToolz

public extension Observer
{
    func observe<O1: BufferedObservable, O2: BufferedObservable, O3: BufferedObservable>(
        _ observable1: O1,
        _ observable2: O2,
        _ observable3: O3,
        _ receive: @escaping (O1.Message, O2.Message, O3.Message) -> Void)
    {
        observe(observable1)
        {
            [weak observable2, weak observable3] in
            guard let o2 = observable2, let o3 = observable3 else { return }
            receive($0, o2.latestMessage, o3.latestMessage)
        }
        
        observe(observable2)
        {
            [weak observable1, weak observable3] in
            guard let o1 = observable1, let o3 = observable3 else { return }
            receive(o1.latestMessage, $0, o3.latestMessage)
        }
        
        observe(observable3)
        {
            [weak observable1, weak observable2] in
            guard let o1 = observable1, let o2 = observable2 else { return }
            receive(o1.latestMessage, o2.latestMessage, $0)
        }
    }
    
    func observe<O1: BufferedObservable, O2: BufferedObservable, O3: BufferedObservable>(
        _ observable1: O1,
        _ observable2: O2,
        _ observable3: O3,
        _ receive: @escaping (O1.Message, O2.Message, O3.Message, AnyAuthor) -> Void)
    {
        observe(observable1)
        {
            [weak observable2, weak observable3] in
            guard let o2 = observable2, let o3 = observable3 else { return }
            receive($0, o2.latestMessage, o3.latestMessage, $1)
        }
        
        observe(observable2)
        {
            [weak observable1, weak observable3] in
            guard let o1 = observable1, let o3 = observable3 else { return }
            receive(o1.latestMessage, $0, o3.latestMessage, $1)
        }
        
        observe(observable3)
        {
            [weak observable1, weak observable2] in
            guard let o1 = observable1, let o2 = observable2 else { return }
            receive(o1.latestMessage, o2.latestMessage, $0, $1)
        }
    }
    
    func observe<O1: BufferedObservable, O2: BufferedObservable>(
        _ observable1: O1,
        _ observable2: O2,
        _ receive: @escaping (O1.Message, O2.Message) -> Void)
    {
        observe(observable1)
        {
            [weak observable2] in
            guard let o2 = observable2 else { return }
            receive($0, o2.latestMessage)
        }
        
        observe(observable2)
        {
            [weak observable1] in
            guard let o1 = observable1 else { return }
            receive(o1.latestMessage, $0)
        }
    }
    
    func observe<O1: BufferedObservable, O2: BufferedObservable>(
        _ observable1: O1,
        _ observable2: O2,
        _ receive: @escaping (O1.Message, O2.Message, AnyAuthor) -> Void)
    {
        observe(observable1)
        {
            [weak observable2] in
            guard let o2 = observable2 else { return }
            receive($0, o2.latestMessage, $1)
        }
        
        observe(observable2)
        {
            [weak observable1] in
            guard let o1 = observable1 else { return }
            receive(o1.latestMessage, $0, $1)
        }
    }
    
    func observe<O: Observable>(_ observable: O,
                                receive: @escaping (O.Message) -> Void)
    {
        let messenger = observable.messenger
        let connection = messenger.connect(self, receive: receive)
        connections.retain(connection, for: messenger.key)
    }
    
    func observe<O: Observable>(_ observable: O,
                                receive: @escaping (O.Message, AnyAuthor) -> Void)
    {
        let messenger = observable.messenger
        let connection = messenger.connect(self, receive: receive)
        connections.retain(connection, for: messenger.key)
    }
    
    func isObserving<O: Observable>(_ observable: O) -> Bool
    {
        observable.messenger.isConnected(self)
    }
    
    func stopObserving<O: Observable>(_ observable: O?)
    {
        observable.forSome
        {
            connections.closeConnection(for: $0.messenger.key)
        }
    }
    
    func stopObserving()
    {
        connections.close()
    }
}

public protocol Observer: AnyReceiver
{
    var connections: Connections { get }
}

public class Connections
{
    public init() {}
    
    internal func retain(_ connection: Connection, for messengerKey: MessengerKey)
    {
        connection.didClose =
        {
            [weak self] in self?.connections[$0.messengerKey] = nil
        }
        
        connections[messengerKey] = connection
    }
    
    internal func closeConnection(for messengerKey: MessengerKey)
    {
        connections[messengerKey]?.close()
    }
    
    internal func close()
    {
        connections.values.forEach { $0.close() }
    }
    
    private var connections = [MessengerKey : Connection]()
}
