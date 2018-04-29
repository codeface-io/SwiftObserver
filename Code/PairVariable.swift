public func +<T1, T2>(_ variable1: AbstractVariable<T1>?,
                      _ variable2: AbstractVariable<T2>?) -> PairVariable<T1, T2>?
{
    guard let v1 = variable1, let v2 = variable2 else { return nil }
    
    return v1 + v2
}

public func +<T1, T2>(_ variable1: AbstractVariable<T1>,
                      _ variable2: AbstractVariable<T2>) -> PairVariable<T1, T2>
{
    return PairVariable(variable1, variable2)
}

// MARK: -

public class PairVariable<Value1, Value2>: AbstractVariable<Pair<Value1, Value2>>
{
    // MARK: Life Cycle
    
    fileprivate init(_ variable1: AbstractVariable<Value1>,
         _ variable2: AbstractVariable<Value2>)
    {
        self.variable1 = variable1
        self.variable2 = variable2
        
        // TODO: does this trigger my (overridden) value setter and therefor the updates of both variables?
        super.init(Pair(variable1.value, variable2.value))
        
        variable1.add(self)
        {
            [weak self] value1 in
            
            guard let me = self else { return }
            
            let oldPair = value1.old +++ me.variable2.value
            let newPair = value1.new +++ me.variable2.value
            
            me.updateObservers(Update(oldPair, newPair))
        }
        
        variable2.add(self)
        {
            [weak self] value2 in
            
            guard let me = self else { return }
            
            let oldPair = me.variable1.value +++ value2.old
            let newPair = me.variable1.value +++ value2.new
            
            me.updateObservers(Update(oldPair, newPair))
        }
    }
    
    deinit
    {
        variable1.remove(self)
        variable2.remove(self)
    }
    
    // MARK: Value
    
    public override var value: Pair<Value1, Value2>
    {
        get
        {
            return variable1.value +++ variable2.value
        }
        
        set
        {
            variable1 <- newValue.left
            variable2 <- newValue.right
        }
    }
    
    // MARK: Combined Variables
    
    private var variable1: AbstractVariable<Value1>
    private var variable2: AbstractVariable<Value2>
}
