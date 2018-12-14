infix operator <-: AssignmentPrecedence

public func <-<Value>(variable: Var<Value>?, value: Value?)
{
    variable?.value = value
}
