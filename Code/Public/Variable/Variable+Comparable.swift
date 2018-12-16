extension Var: Comparable where Value: Comparable
{
    public static func < (lhs: Variable<Value>,
                          rhs: Variable<Value>) -> Bool
    {
        return lhs.value < rhs.value
    }
}
