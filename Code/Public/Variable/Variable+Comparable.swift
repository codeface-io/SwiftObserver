extension Var: Comparable where Value: Comparable
{
    public static func < (lhs: Variable<Value>,
                          rhs: Variable<Value>) -> Bool
    {
        lhs.value < rhs.value
    }
}
