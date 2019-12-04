public extension Observer
{
    func isObserving<O: Observable>(_ observable: O) -> Bool
    {
        observable.messenger.isConnected(to: self)
    }
    
    func observe<O: Observable>(_ observable: O,
                                receive: @escaping (O.Message) -> Void)
    {
        observable.connect(self, receive: receive)
    }
    
    func observe<O: Observable>(_ observable: O,
                                receive: @escaping (O.Message, AnyAuthor) -> Void)
    {
        observable.connect(self, receive: receive)
    }
    
    func observe<O1: BufferedObservable, O2: BufferedObservable>(
        _ observable1: O1,
        _ observable2: O2,
        _ receive: @escaping (O1.Message, O2.Message) -> Void)
    {
        observable1.connect(self)
        {
            [weak observable2] in
            
            guard let o2 = observable2 else { return }
            
            receive($0, o2.latestMessage)
        }
        
        observable2.connect(self)
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
        observable1.connect(self)
        {
            [weak observable2] in
            
            guard let o2 = observable2 else { return }
            
            receive($0, o2.latestMessage, $1)
        }
        
        observable2.connect(self)
        {
            [weak observable1] in
            
            guard let o1 = observable1 else { return }
            
            receive(o1.latestMessage, $0, $1)
        }
    }
    
    func observe<O1: BufferedObservable, O2: BufferedObservable, O3: BufferedObservable>(
        _ observable1: O1,
        _ observable2: O2,
        _ observable3: O3,
        _ receive: @escaping (O1.Message, O2.Message, O3.Message) -> Void)
    {
        observable1.connect(self)
        {
            [weak observable2, weak observable3] in
            
            guard let o2 = observable2, let o3 = observable3 else { return }
            
            receive($0, o2.latestMessage, o3.latestMessage)
        }
        
        observable2.connect(self)
        {
            [weak observable1, weak observable3] in
            
            guard let o1 = observable1, let o3 = observable3 else { return }
            
            receive(o1.latestMessage, $0, o3.latestMessage)
        }
        
        observable3.connect(self)
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
        observable1.connect(self)
        {
            [weak observable2, weak observable3] in
            
            guard let o2 = observable2, let o3 = observable3 else { return }
            
            receive($0, o2.latestMessage, o3.latestMessage, $1)
        }
        
        observable2.connect(self)
        {
            [weak observable1, weak observable3] in
            
            guard let o1 = observable1, let o3 = observable3 else { return }
            
            receive(o1.latestMessage, $0, o3.latestMessage, $1)
        }
        
        observable3.connect(self)
        {
            [weak observable1, weak observable2] in
            
            guard let o1 = observable1, let o2 = observable2 else { return }
            
            receive(o1.latestMessage, o2.latestMessage, $0, $1)
        }
    }
    
    func stopObserving<O: Observable>(_ observable: O?)
    {
        observable?.messenger.disconnect(self)
    }
    
    func stopObserving()
    {
        ConnectionRegistry.shared.disconnectFromMessengers(self)
    }
}

public protocol Observer: AnyReceiver {}

private extension Observable
{
    func connect(_ receiver: AnyReceiver,
                 receive: @escaping (Message, AnyAuthor) -> Void)
    {
        messenger.connect(receiver, receive: receive)
    }
    
    func connect(_ receiver: AnyReceiver,
                 receive: @escaping (Message) -> Void)
    {
        messenger.connect(receiver) { message, _ in receive(message) }
    }
}
