import SwiftyToolz

public extension ObservableCache
{
    func cache<Unwrapped>() -> CacheOnOptionalMessage<Self, Unwrapped>
    {
        log(warning: warningWhenApplyingCache(messageIsOptional: true))
        return CacheOnOptionalMessage(self)
    }

    func cache<Unwrapped>() -> Cache<Self, Unwrapped>
    {
        log(warning: warningWhenApplyingCache(messageIsOptional: false))
        return Cache(self)
    }
}

internal extension ObservableCache
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
    func cache<Unwrapped>() -> CacheOnOptionalMessage<Self, Unwrapped>
    {
        CacheOnOptionalMessage(self)
    }

    func cache<Unwrapped>() -> Cache<Self, Unwrapped>
    {
        Cache(self)
    }
}
