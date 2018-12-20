// Mark: - Calculation Operators

infix operator +: AdditionPrecedence

public func +<N1: FloatValue, N2: FloatValue>(num1: N1, num2: N2) -> Float
{
    return num1.float + num2.float
}

infix operator -: AdditionPrecedence

public func -<N1: FloatValue, N2: FloatValue>(num1: N1, num2: N2) -> Float
{
    return num1.float - num2.float
}

infix operator *: MultiplicationPrecedence

public func *<N1: FloatValue, N2: FloatValue>(num1: N1, num2: N2) -> Float
{
    return num1.float * num2.float
}

infix operator /: MultiplicationPrecedence

public func /<N1: FloatValue, N2: FloatValue>(num1: N1, num2: N2) -> Float
{
    return num1.float / num2.float
}

// Mark: - Extensions

extension Var: FloatValue where Value: FloatValue
{
    public var float: Float
    {
        get { return value.float }
        set { value.float = newValue }
    }
}

extension Float: FloatValue
{
    public var float: Float
    {
        get { return self }
        set { self = newValue }
    }
}

extension Optional: FloatValue where Wrapped: FloatValue
{
    public var float: Float
    {
        get { return self?.float ?? 0 }
        set { self?.float = newValue }
    }
}

public protocol FloatValue
{
    var float: Float { get set }
}
