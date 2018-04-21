import UIKit

public class MessagePresenter: MessageLogDelegate
{
    // MARK: - Singleton Access
    
    public static let sharedInstance = MessagePresenter()
    
    private init() {}
    
    // MARK: - Presenting Messages to the User/Tester
    
    public func messageLogReceived(message: String,
                                   of type: LogMessageType)
    {
        guard type != .warning || isPresentingWarnings,
            type != .error || isPresentingErrors
        else
        {
            return
        }
        
        presentMessage(Message(title: type.rawValue, text: message))
    }
    
    public var isPresentingWarnings = true
    public var isPresentingErrors = true
    
    public func presentMessage(_ message: Message)
    {
        messageQueue.append(message)
       
        if !isShowingAlert
        {
            presentQueuedMessages()
        }
    }
    
    public struct Message
    {
        var title: String
        var text: String
    }
    
    private func presentQueuedMessages()
    {
        guard messageQueue.count > 0 else
        {
            return
        }
        
        isShowingAlert = true
        
        let message = messageQueue.removeFirst()
        
        let alert = Alert(title: message.title,
                          message: message.text,
                          preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default)
        {
            (action) in
            
            if self.messageQueue.count > 0
            {
                self.presentQueuedMessages()
            }
            else
            {
                self.isShowingAlert = false
            }
        }
        
        alert.addAction(action)
        
        DispatchQueue.main.async
        {
            alert.show()
        }
    }
    
    private var messageQueue = [Message]()
    private var isShowingAlert = false
}
