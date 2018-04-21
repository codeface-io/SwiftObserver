import AppKit

public class MessagePresenter: MessageLogDelegate
{
    private init() {}
    
    public static let sharedInstance = MessagePresenter()
    
    public func messageLogReceived(message: String,
                                   of type: LogMessageType)
    {
        switch type
        {
            case .info:
                showAlert(message, .informational, type.rawValue)
            case .warning:
                showAlert(message, .warning, type.rawValue)
            case .error:
                showAlert(message, .critical, type.rawValue)
        }
    }
    
    private func showAlert(_ message: String,
                           _ alertStyle: NSAlert.Style,
                           _ title: String)
    {
        let alert = NSAlert()
        
        alert.alertStyle = alertStyle
        alert.messageText = title
        alert.informativeText = message
        alert.addButton(withTitle: "OK")
        
        alert.runModal()
    }
}
