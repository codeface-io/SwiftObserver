infix operator <-: AdditionPrecedence

@discardableResult
public func <-<Value>(variable: AbstractVariable<Value>?,
                      value: Value) -> AbstractVariable<Value>?
{
    variable?.value = value
    return variable
}

public class AbstractVariable<ValueType>: AbstractObservable<Update<ValueType>>
{
    // MARK: Update Observers When They Start Observing
    
    public override func add(_ observer: AnyObject,
                             _ receive: @escaping (Update<ValueType>) -> Void)
    {
        super.add(observer, receive)
        
        receive(latestUpdate)
    }
    
    // MARK: Value
    
    init(_ value: ValueType)
    {
        self.value = value
        
        super.init(Update(value, value))
    }
    
    public override var latestUpdate: UpdateType
    {
        get
        {
            let currentValue = value
            
            return Update(currentValue, currentValue)
        }
        
        set {}
    }
    
    public var value: ValueType
}
