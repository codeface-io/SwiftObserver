public class Messenger<Message>: ObservableObject<Message>
{
    init(initialMessage: Message)
    {
        message = initialMessage
        
        super.init()
    }
    
    public override func send(_ update: Message)
    {
        message = update
        
        super.send(update)
    }
    
    public override var latestUpdate: Message
    {
        return message
    }
    
    private var message: Message
}
