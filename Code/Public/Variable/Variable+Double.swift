// Mark: - Calculation Operators

infix operator +: AdditionPrecedence

public func +<N1: DoubleValue, N2: DoubleValue>(num1: N1, num2: N2) -> Double
{
    return num1.double + num2.double
}

infix operator -: AdditionPrecedence

public func -<N1: DoubleValue, N2: DoubleValue>(num1: N1, num2: N2) -> Double
{
    return num1.double - num2.double
}

infix operator *: MultiplicationPrecedence

public func *<N1: DoubleValue, N2: DoubleValue>(num1: N1, num2: N2) -> Double
{
    return num1.double * num2.double
}

infix operator /: MultiplicationPrecedence

public func /<N1: DoubleValue, N2: DoubleValue>(num1: N1, num2: N2) -> Double
{
    return num1.double / num2.double
}

// Mark: - Assignment Operators

infix operator +=: AssignmentPrecedence

public func +=<N1: DoubleValue, N2: DoubleValue>(num1: inout N1, num2: N2)
{
    num1.double = num1.double + num2.double
}

public func +=<N1: DoubleVar, N2: DoubleValue>(num1: N1, num2: N2)
{
    num1.double = num1.double + num2.double
}

infix operator -=: AssignmentPrecedence

public func -=<N1: DoubleValue, N2: DoubleValue>(num1: inout N1, num2: N2)
{
    num1.double = num1.double - num2.double
}

public func -=<N1: DoubleVar, N2: DoubleValue>(num1: N1, num2: N2)
{
    num1.double = num1.double - num2.double
}

infix operator *=: AssignmentPrecedence

public func *=<N1: DoubleValue, N2: DoubleValue>(num1: inout N1, num2: N2)
{
    num1.double = num1.double * num2.double
}

public func *=<N1: DoubleVar, N2: DoubleValue>(num1: N1, num2: N2)
{
    num1.double = num1.double * num2.double
}

infix operator /=: AssignmentPrecedence

public func /=<N1: DoubleValue, N2: DoubleValue>(num1: inout N1, num2: N2)
{
    num1.double = num1.double / num2.double
}

public func /=<N1: DoubleVar, N2: DoubleValue>(num1: N1, num2: N2)
{
    num1.double = num1.double / num2.double
}

// Mark: - Extensions

extension Var: DoubleVar, DoubleValue where Value: DoubleValue
{
    public var double: Double
    {
        get { return value.double }
        set { value.double = newValue }
    }
}

public protocol DoubleVar: AnyObject
{
    var double: Double { get set }
}

extension Double: DoubleValue
{
    public var double: Double
    {
        get { return self }
        set { self = newValue }
    }
}

extension Optional: DoubleValue where Wrapped: DoubleValue
{
    public var double: Double
    {
        get { return self?.double ?? 0 }
        set { self?.double = newValue }
    }
}

public protocol DoubleValue
{
    var double: Double { get set }
}
