infix operator <-: AdditionPrecedence

@discardableResult
public func <-<Value>(variable: AbstractVariable<Value>?,
                      value: Value) -> AbstractVariable<Value>?
{
    variable?.value = value
    return variable
}

public class AbstractVariable<Value>: Observable
{
    init(_ value: Value)
    {
        self.value = value
    }
    
    public func add(_ observer: AnyObject,
                    _ receive: @escaping (Update<Value>) -> Void)
    {
        ObservationService.add(observer, of: self)
        {
            guard let update = $0 as? Update<Value> else
            {
                fatalError("Impossible error: could not cast update type received from observation center")
            }
            
            receive(update)
        }
        
        receive(latestUpdate)
    }
    
    public var latestUpdate: Update<Value>
    {
        let currentValue = value
        
        return Update(currentValue, currentValue)
    }
    
    public var value: Value
}
