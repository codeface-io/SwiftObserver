extension Variable: Equatable where Value: Equatable
{
    public static func == (lhs: Variable<Value>, rhs: Variable<Value>) -> Bool
    {
        return lhs.value == rhs.value
    }
}
