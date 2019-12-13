// MARK: - Concatenation Operator

infix operator +: AdditionPrecedence

public func +<S1: StringValue, S2: StringValue>(str1: S1, str2: S2) -> String
{
    return str1.string + str2.string
}

// MARK: - StringValue

extension Var: StringValue where Value: StringValue
{
    public var string: String
    {
        get { value.string }
        set { value.string = newValue }
    }
}

extension String: StringValue
{
    public var string: String
    {
        get { self }
        set { self = newValue }
    }
}

extension Optional: StringValue where Wrapped: StringValue
{
    public var string: String
    {
        get { self?.string ?? "" }
        set { self?.string = newValue }
    }
}

public protocol StringValue
{
    var string: String { get set }
}
