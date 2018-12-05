extension Var: Comparable where Value: Comparable
{
    public static func < (lhs: Variable<Value>,
                          rhs: Variable<Value>) -> Bool
    {
        guard let lhsValue = lhs.value else { return false }
        guard let rhsValue = rhs.value else { return true }
        
        return lhsValue < rhsValue
    }
}
