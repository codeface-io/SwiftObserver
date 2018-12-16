import SwiftyToolz

public class Messenger<Message>: ObservableObject<Message>
{
    public convenience init<Wrapped>() where Message == Optional<Wrapped>
    {
        self.init(nil)
    }
    
    public init(_ initialMessage: Message)
    {
        latestMessage = initialMessage
        
        super.init()
    }
    
    public override func send(_ update: Message)
    {
        if remembersLatestMessages { latestMessage = update }
        
        super.send(update)
    }
    
    public override var latestUpdate: Message
    {
        return latestMessage
    }
    
    public var remembersLatestMessages = true
    
    public private(set) var latestMessage: Message
}
