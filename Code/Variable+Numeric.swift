// MARK: - Value Mutation with Numeric

infix operator +=: AssignmentPrecedence

public func +=<Number: Numeric>(numVar: Var<Number>?, addition: Number)
{
    guard let numVar = numVar else { return }
    
    numVar.number = numVar.number + addition
}

infix operator -=: AssignmentPrecedence

public func -=<Number: Numeric>(numVar: Var<Number>?, subtraction: Number)
{
    guard let numVar = numVar else { return }
    
    numVar.number = numVar.number - subtraction
}

infix operator *=: AssignmentPrecedence

public func *=<Number: Numeric>(numVar: Var<Number>?, factor: Number)
{
    guard let numVar = numVar else { return }
    
    numVar.number = numVar.number * factor
}

// MARK: - Value Mutation with Var<Numeric>

extension Var where Value: Numeric
{
    public static func += (lhs: inout Variable<Value>,
                           rhs: Variable<Value>)
    {
        lhs.value = lhs.number + rhs.number
    }
    
    public static func -= (lhs: inout Variable<Value>,
                           rhs: Variable<Value>)
    {
        lhs.number = lhs.number - rhs.number
    }
    
    public static func *= (lhs: inout Variable<Value>,
                           rhs: Variable<Value>)
    {
        lhs.number = lhs.number * rhs.number
    }
}

// MARK: - Composing Pairs of Var<Numeric>

extension Var where Value: Numeric
{
    public static func + (lhs: Variable<Value>,
                          rhs: Variable<Value>) -> Var<Value>
    {
        return Var(lhs.number + rhs.number)
    }
    
    public static func - (lhs: Variable<Value>,
                          rhs: Variable<Value>) -> Var<Value>
    {
        return Var(lhs.number - rhs.number)
    }
    
    public static func * (lhs: Variable<Value>,
                          rhs: Variable<Value>) -> Var<Value>
    {
        return Var(lhs.number * rhs.number)
    }
}

// MARK: - Basic Numeric Stuff

extension Var where Value: Numeric
{
    public var number: Value
    {
        get { return value ?? 0 }
        set { value = newValue }
    }
    
    public var magnitude: Value.Magnitude
    {
        return value?.magnitude ?? 0
    }
}
