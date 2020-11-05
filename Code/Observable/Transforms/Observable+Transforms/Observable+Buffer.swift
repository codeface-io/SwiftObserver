import SwiftyToolz

public extension BufferedObservable
{
    func buffer<Unwrapped>() -> BufferForOptionalMessage<Self, Unwrapped>
    {
        log(warning: warningWhenApplyingBuffer(messageIsOptional: true))
        return BufferForOptionalMessage(self)
    }

    func buffer<Unwrapped>() -> BufferForNonOptionalMessage<Self, Unwrapped>
    {
        log(warning: warningWhenApplyingBuffer(messageIsOptional: false))
        return BufferForNonOptionalMessage(self)
    }
}

internal extension BufferedObservable
{
    func warningWhenApplyingBuffer(messageIsOptional: Bool) -> String
    {
        var warning = "\(Self.self) is already a BufferedObservable. Buffering it again is likely pointless."
        
        if !messageIsOptional
        {
            warning += " And making the \(Message.self) message optional is likely unnecessary."
        }
        
        return warning
    }
}

public extension Observable
{
    func buffer<Unwrapped>() -> BufferForOptionalMessage<Self, Unwrapped>
    {
        BufferForOptionalMessage(self)
    }

    func buffer<Unwrapped>() -> BufferForNonOptionalMessage<Self, Unwrapped>
    {
        BufferForNonOptionalMessage(self)
    }
}
