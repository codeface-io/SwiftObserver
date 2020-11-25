import Dispatch
import SwiftyToolz

public class Promise<Value>: Observable
{
    public static func fulfilled(_ value: Value) -> Promise
    {
        Promise(value)
    }
    
    internal convenience init(_ value: Value)
    {
        self.init()
        state = .fulfilled(value)
    }
    
    public convenience init(fulfill: (Self) -> Void)
    {
        self.init()
        fulfill(self)
    }
    
    public func fulfill(_ value: Value)
    {
        if case .unfulfilled = state
        {
            log(warning: "Tried to fulfill an already fulfilled Promise")
        }
        
        state = .fulfilled(value)
        send(.wasFulfilled(value))
    }
    
    @discardableResult
    public func whenFulfilled(_ handleValue: @escaping (Value) -> Void) -> Self
    {
        switch state
        {
        case .fulfilled(let value):
            handleValue(value)
        case .unfulfilled:
            observedOnce
            {
                switch $0
                {
                case .wasFulfilled(let value):
                    handleValue(value)
                }
            }
        }
        
        return self
    }
    
    public private(set) var state: State = .unfulfilled
    public enum State { case unfulfilled, fulfilled(Value) }
    
    public let messenger = Messenger<Event>()
    public enum Event { case wasFulfilled(Value) }
}
