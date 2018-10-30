public func log(error: String,
                file: String = #file,
                function: String = #function,
                line: Int = #line)
{
    Log.shared.log(message: error,
                   level: .error,
                   file: file,
                   function: function,
                   line: line)
}

public func log(warning: String,
                file: String = #file,
                function: String = #function,
                line: Int = #line)
{
    Log.shared.log(message: warning,
                   level: .warning,
                   file: file,
                   function: function,
                   line: line)
}

public func log(_ message: String,
                file: String = #file,
                function: String = #function,
                line: Int = #line)
{
    Log.shared.log(message: message,
                   level: .info,
                   file: file,
                   function: function,
                   line: line)
}

public class Log
{
    // MARK: - Singleton Access
    
    public static let shared = Log()
    
    private init() {}
    
    // MARK: - Logging
    
    public func log(message: String,
                    level: Level = .info,
                    file: String = #file,
                    function: String = #function,
                    line: Int = #line)
    {
        guard level.integer >= minimumLevel.integer else { return }
        
        var logString = ""
        
        if level != .info
        {
            if logString.count > 0 { logString += " " }
            
            logString += level.rawValue.uppercased()
        }
        
        if logString.count > 0 { logString += ": " }
        
        logString += message
        
        let filename = file.components(separatedBy: "/").last ?? file
        
        logString += " (\(filename), \(function), line \(line))"
        
        print(logString)
    }
    
    // MARK: - Observability
    
    public let latestEntry = Var<Entry>()
    
    public struct Entry: Codable, Equatable
    {
        var message = ""
        var level = Level.info
        var file = ""
        var function = ""
        var line = 0
    }
    
    // MARK: - Log Levels
    
    public var minimumLevel: Level = .info
    
    public enum Level: String, Codable, Equatable
    {
        var integer: Int
        {
            switch self
            {
            case .info: return 0
            case .warning: return 1
            case .error: return 2
            case .off: return 3
            }
        }
        
        case info, warning, error, off
    }
}
