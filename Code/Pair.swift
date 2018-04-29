// MARK: - Value Pair Operator

infix operator +++: MultiplicationPrecedence

public func +++<T1, T2>(_ left: T1, _ right: T2) -> Pair<T1, T2>
{
    return Pair(left, right)
}

// MARK: - Value Pair

public struct Pair<T1, T2>
{
    public init(_ left: T1, _ right: T2)
    {
        self.left = left
        self.right = right
    }
    
    public let left: T1
    public let right: T2
}

