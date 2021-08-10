@propertyWrapper
public struct Observable<Value: Equatable>
{
    public var projectedValue: Var<Value> { observableVariable }
    
    public var wrappedValue: Value
    {
        get { observableVariable.value }
        set { observableVariable <- newValue }
    }
    
    public init(wrappedValue: Value)
    {
        observableVariable = Var(wrappedValue)
    }
    
    private let observableVariable: Var<Value>
}
