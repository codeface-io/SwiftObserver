// Mark: - Calculation Operators

infix operator +: AdditionPrecedence

public func +<N1: IntValue, N2: IntValue>(num1: N1, num2: N2) -> Int
{
    return num1.int + num2.int
}

infix operator -: AdditionPrecedence

public func -<N1: IntValue, N2: IntValue>(num1: N1, num2: N2) -> Int
{
    return num1.int - num2.int
}

infix operator *: MultiplicationPrecedence

public func *<N1: IntValue, N2: IntValue>(num1: N1, num2: N2) -> Int
{
    return num1.int * num2.int
}

infix operator /: MultiplicationPrecedence

public func /<N1: IntValue, N2: IntValue>(num1: N1, num2: N2) -> Int
{
    return num1.int / num2.int
}

// Mark: - Extensions

extension Var: IntValue where Value: IntValue
{
    public var int: Int
    {
        get { return value.int }
        set { value.int = newValue }
    }
}

extension Int: IntValue
{
    public var int: Int
    {
        get { return self }
        set { self = newValue }
    }
}

extension Optional: IntValue where Wrapped: IntValue
{
    public var int: Int
    {
        get { return self?.int ?? 0 }
        set { self?.int = newValue }
    }
}

public protocol IntValue
{
    var int: Int { get set }
}
