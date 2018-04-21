public protocol MessageLogger: AnyObject
{
    func log(error: String)
    func log(warning: String)
    func log(_ message: String)
}

public extension MessageLogger
{
    func log(error: String)
    {
        MessageLog.sharedInstance.log(sender: self,
                                      message: error,
                                      type: .error)
    }
    
    func log(warning: String)
    {
        MessageLog.sharedInstance.log(sender: self,
                                      message: warning,
                                      type: .warning)
    }
    
    func log(_ message: String)
    {
        MessageLog.sharedInstance.log(sender: self,
                                      message: message,
                                      type: .info)
    }
}

public class MessageLog
{
    // MARK: - Singleton Access
    
    public static let sharedInstance = MessageLog()
    
    private init() {}
    
    // MARK: - Logging
    
    public func log(sender: AnyObject?, message: String, type: LogMessageType)
    {
        var logString = typeName(of: sender)
        
        if type != .info
        {
            logString += " " + type.rawValue.uppercased()
        }
        
        logString += ": " + message
        
        print(logString)
        
        self.delegate?.messageLogReceived(message: logString, of: type)
    }
    
    // MARK: - Delegate
    
    public weak var delegate: MessageLogDelegate?
}

public protocol MessageLogDelegate: AnyObject
{
    func messageLogReceived(message: String,
                            of type: LogMessageType)
}

public enum LogMessageType: String
{
    case info = "Info"
    case warning = "Warning"
    case error = "Error"
}
