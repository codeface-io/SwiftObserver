// MARK: - Addition

infix operator +: AdditionPrecedence

public func +<Number: Numeric>(numVar: Var<Number>?,
                               num: Number?) -> Number
{
    return (numVar?.number ?? 0) + (num ?? 0)
}

public func +<Number: Numeric>(num: Number?,
                               numVar: Var<Number>?) -> Number
{
    return (numVar?.number ?? 0) + (num ?? 0)
}

infix operator +=: AssignmentPrecedence

public func +=<Number: Numeric>(numVar: Var<Number>?, num: Number?)
{
    numVar?.number += (num ?? 0)
}

public func +=<Number: Numeric>(num: inout Number, numVar: Var<Number>?)
{
    num += (numVar?.number ?? 0)
}

// MARK: - Subtraction

infix operator -: AdditionPrecedence

public func -<Number: Numeric>(numVar: Var<Number>?,
                               num: Number?) -> Number
{
    return (numVar?.number ?? 0) - (num ?? 0)
}

public func -<Number: Numeric>(num: Number?,
                               numVar: Var<Number>?) -> Number
{
    return (num ?? 0) - (numVar?.number ?? 0)
}

infix operator -=: AssignmentPrecedence

public func -=<Number: Numeric>(numVar: Var<Number>?, num: Number?)
{
    numVar?.number -= (num ?? 0)
}

public func -=<Number: Numeric>(num: inout Number, numVar: Var<Number>?)
{
    num -= (numVar?.number ?? 0)
}

// MARK: - Multiplication

infix operator *: MultiplicationPrecedence

public func *<Number: Numeric>(numVar: Var<Number>?,
                               num: Number?) -> Number
{
    return (numVar?.number ?? 0) * (num ?? 0)
}

public func *<Number: Numeric>(num: Number?,
                               numVar: Var<Number>?) -> Number
{
    return (numVar?.number ?? 0) * (num ?? 0)
}

infix operator *=: AssignmentPrecedence

public func *=<Number: Numeric>(numVar: Var<Number>?, num: Number?)
{
    numVar?.number *= (num ?? 0)
}

public func *=<Number: Numeric>(num: inout Number, numVar: Var<Number>?)
{
    num *= (numVar?.number ?? 0)
}

// TODO: Allow all operands below to be optional

// MARK: - Value Mutation with Var<Numeric>

extension Var where Value: Numeric
{
    public static func += (lhs: Variable<Value>,
                           rhs: Variable<Value>)
    {
        lhs.number += rhs.number
    }
    
    public static func += (lhs: Variable<Value>,
                           rhs: Variable<Value>?)
    {
        lhs.number += (rhs?.number ?? 0)
    }
    
    public static func += (lhs: Variable<Value>?,
                           rhs: Variable<Value>)
    {
        lhs?.number += rhs.number
    }
    
    public static func -= (lhs: Variable<Value>,
                           rhs: Variable<Value>)
    {
        lhs.number -= rhs.number
    }
    
    public static func -= (lhs: Variable<Value>,
                           rhs: Variable<Value>?)
    {
        lhs.number -= (rhs?.number ?? 0)
    }
    
    public static func -= (lhs: Variable<Value>?,
                           rhs: Variable<Value>)
    {
        lhs?.number -= rhs.number
    }
    
    public static func *= (lhs: Variable<Value>,
                           rhs: Variable<Value>)
    {
        lhs.number *= rhs.number
    }
    
    public static func *= (lhs: Variable<Value>,
                           rhs: Variable<Value>?)
    {
        lhs.number *= (rhs?.number ?? 0)
    }
    
    public static func *= (lhs: Variable<Value>?,
                           rhs: Variable<Value>)
    {
        lhs?.number *= rhs.number
    }
}

// MARK: - Composing Pairs of Var<Numeric> Into Numeric

extension Var where Value: Numeric
{
    public static func + (lhs: Variable<Value>,
                          rhs: Variable<Value>) -> Value
    {
        return lhs.number + rhs.number
    }
    
    public static func - (lhs: Variable<Value>,
                          rhs: Variable<Value>) -> Value
    {
        return lhs.number - rhs.number
    }

    public static func * (lhs: Variable<Value>,
                          rhs: Variable<Value>) -> Value
    {
        return lhs.number * rhs.number
    }
}

// MARK: - Basic Numeric Stuff

extension Var where Value: Numeric
{
    public var number: Value
    {
        get { return value }
        set { value = newValue }
    }
    
    public var magnitude: Value.Magnitude
    {
        return value.magnitude
    }
}
