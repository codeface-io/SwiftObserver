import SwiftyToolz

public extension Cache
{
    func cache<Unwrapped>() -> CacheForOptionalMessage<Self, Unwrapped>
    {
        log(warning: warningWhenApplyingCache(messageIsOptional: true))
        return CacheForOptionalMessage(self)
    }

    func cache<Unwrapped>() -> CacheForNonOptionalMessage<Self, Unwrapped>
    {
        log(warning: warningWhenApplyingCache(messageIsOptional: false))
        return CacheForNonOptionalMessage(self)
    }
}

internal extension Cache
{
    func warningWhenApplyingCache(messageIsOptional: Bool) -> String
    {
        var warning = "\(Self.self) is already a Cache. Creating another Cache with it is likely pointless."
        
        if !messageIsOptional
        {
            warning += " And making the \(Message.self) message optional is likely unnecessary."
        }
        
        return warning
    }
}

public extension Observable
{
    func cache<Unwrapped>() -> CacheForOptionalMessage<Self, Unwrapped>
    {
        CacheForOptionalMessage(self)
    }

    func cache<Unwrapped>() -> CacheForNonOptionalMessage<Self, Unwrapped>
    {
        CacheForNonOptionalMessage(self)
    }
}
