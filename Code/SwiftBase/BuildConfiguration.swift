public let buildConfiguration: BuildConfiguration =
{
    #if DEBUG
        return .debug
    #elseif INTEGRATION
        return .integration
    #elseif RELEASE
        return .release
    #else
        print("Warning: Build configuration is unknown. Set DEBUG=1, INTEGRATION=1, RELEASE=1 in 'prepocessor macros' and -D DEBUG, -D INTEGRATION, -D RELEASE in 'other swift flags'")
        return .unknown
    #endif
}()

public enum BuildConfiguration: String
{
    case debug, integration, release, unknown
    
    public var isDebug: Bool
    {
        return self == .debug
    }
    
    public var isIntegration: Bool
    {
        return self == .integration
    }
    
    public var isRelease: Bool
    {
        return self == .release
    }
    
    public var isUnknown: Bool
    {
        return self == .unknown
    }
}
