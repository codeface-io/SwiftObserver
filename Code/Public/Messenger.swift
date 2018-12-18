import SwiftyToolz

public class Messenger<Message>: ObservableObject<Message>
{
    public convenience init<Wrapped>() where Message == Optional<Wrapped>
    {
        self.init(nil)
    }
    
    public init(_ initialMessage: Message)
    {
        storedLatestMessage = initialMessage
        
        super.init()
    }
    
    public override func send(_ message: Message)
    {
        if remembersLatestMessage { storedLatestMessage = message }
        
        super.send(message)
    }
    
    public override var latestMessage: Message
    {
        get { return storedLatestMessage }
        set { storedLatestMessage = newValue }
    }
    
    public var remembersLatestMessage = true
    
    private var storedLatestMessage: Message
}
