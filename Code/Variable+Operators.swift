// MARK: - Number Operators

infix operator +=: AssignmentPrecedence

public func +=<Number: Numeric>(variable: Var<Number>?, addition: Number)
{
    variable?.value = (variable?.value ?? 0) + addition
}

infix operator -=: AssignmentPrecedence

public func -=<Number: Numeric>(variable: Var<Number>?, addition: Number)
{
    variable?.value = (variable?.value ?? 0) - addition
}

// MARK: - Assignment Operator

infix operator <-: AssignmentPrecedence

public func <-<Value>(variable: Var<Value>?, value: Value?)
{
    variable?.value = value
}
