/**
 Make an `Equatable` variable property observable by ``Observer``s
 
 The ``projectedValue`` provides the actual ``Variable`` so it can be observed:
 
 ```swift
 @ObservableVar var number = 7
 
 observer.observe($number) { numberUpdate in
     let numberChange = numberUpdate.new - numberUpdate.old
 }
 ```
 */
@propertyWrapper
public struct ObservableVar<Value: Equatable>
{
    public var projectedValue: Var<Value> { variable }
    
    public var wrappedValue: Value
    {
        get { variable.value }
        set { variable.value = newValue }
    }
    
    public init(wrappedValue: Value)
    {
        variable = Var(wrappedValue)
    }
    
    private let variable: Var<Value>
}
