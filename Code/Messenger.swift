import SwiftyToolz

public class Messenger<Message>: ObservableObject<Message?>
{
    public init(file: String = #file, line: Int = #line)
    {
        if isOptional(Message.self)
        {
            fatalError("SwiftObserver.Messenger: Message types are not supposed to be optional. Type: \(String(describing: Message.self)), File: \(file), line \(line)")
        }
        
        super.init()
    }
    
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
