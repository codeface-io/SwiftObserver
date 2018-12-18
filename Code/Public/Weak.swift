public class Weak<O: Observable>: ObservableObject<O.Message>, Observer
{
    // MARK: - Life Cycle
    
    public init(_ observable: O)
    {
        self.observable = observable
        self.storedLatestMessage = observable.latestMessage
        
        super.init()
        
        observe(observable) { [weak self] in self?.send($0) }
    }
    
    deinit { stopObserving(observable) }
    
    // MARK: - Latest Message
    
    public override var latestMessage: O.Message
    {
        refreshLatestStoredMessage()
        
        return storedLatestMessage
    }
    
    private func refreshLatestStoredMessage()
    {
        if let latestOriginalMessage = observable?.latestMessage
        {
            storedLatestMessage = latestOriginalMessage
        }
    }
    
    private var storedLatestMessage: O.Message
    
    // MARK: - Observable
    
    public private(set) weak var observable: O?
}
