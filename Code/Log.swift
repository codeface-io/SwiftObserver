public func log(error: String,
                title: String? = nil,
                forUser: Bool = false,
                file: String = #file,
                function: String = #function,
                line: Int = #line)
{
    Log.shared.log(message: error,
                   title: title,
                   level: .error,
                   forUser: forUser,
                   file: file,
                   function: function,
                   line: line)
}

public func log(warning: String,
                title: String? = nil,
                forUser: Bool = false,
                file: String = #file,
                function: String = #function,
                line: Int = #line)
{
    Log.shared.log(message: warning,
                   title: title,
                   level: .warning,
                   forUser: forUser,
                   file: file,
                   function: function,
                   line: line)
}

public func log(_ message: String,
                title: String? = nil,
                forUser: Bool = false,
                file: String = #file,
                function: String = #function,
                line: Int = #line)
{
    Log.shared.log(message: message,
                   title: title,
                   level: .info,
                   forUser: forUser,
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
    
    public static var prefix = ""
    
    public func log(message: String,
                    title: String? = nil,
                    level: Level = .info,
                    forUser: Bool = false,
                    file: String = #file,
                    function: String = #function,
                    line: Int = #line)
    {
        guard level.integer >= minimumLevel.integer else { return }
        
        var logString = Log.prefix
        
        if level != .info
        {
            if logString.count > 0 { logString += " " }
            
            logString += level.rawValue.uppercased()
        }
        
        if logString.count > 0 { logString += ": " }
        
        logString += message
        
        let filename = file.components(separatedBy: "/").last ?? file
        
        let entry = Entry(message: message,
                          title: title,
                          level: level,
                          forUser: forUser,
                          file: filename,
                          function: function,
                          line: line)
        
        logString += " (\(entry.context))"
        
        print(logString)
        
        latestEntry <- entry
    }
    
    // MARK: - Observability
    
    public let latestEntry = Var<Entry>()
    
    public struct Entry: Codable, Equatable
    {
        public var context: String
        {
            return "\(file), \(function), line \(line)"
        }
        
        public var message = ""
        public var title: String?
        public var level = Level.info
        public var forUser = false
        public var file = ""
        public var function = ""
        public var line = 0
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
