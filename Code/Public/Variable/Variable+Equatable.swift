extension Variable: Equatable where Value: Equatable
{
    public static func == (lhs: Variable<Value>, rhs: Variable<Value>) -> Bool
    {
        lhs.value == rhs.value
    }
}
