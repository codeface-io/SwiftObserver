public class Messenger<Message>: ObservableObject<Message?>
{
    public override func send(_ update: Message?)
    {
        message = update
        
        super.send(update)
    }
    
    public override var latestUpdate: Message?
    {
        return message
    }
    
    private var message: Message?
}
