// MARK: - Concatenating

infix operator +: AdditionPrecedence

public func + (strVar: Var<String>?, append: String) -> String
{
    return (strVar?.string ?? "") + append
}

infix operator +=: AssignmentPrecedence

public func += (strVar: Var<String>?, append: String)
{
    strVar?.string += append
}

extension Var where Value == String
{
    public static func + (lhs: Variable<Value>,
                          rhs: Variable<Value>) -> Value
    {
        return lhs.string + rhs.string
    }
    
    public static func += (lhs: inout Variable<Value>,
                           rhs: Variable<Value>)
    {
        lhs.string += rhs.string
    }
}

// MARK: - Protocol Conformances

extension Var:
    CustomStringConvertible,
    CustomDebugStringConvertible,
    TextOutputStream,
    Sequence,
    Collection,
    BidirectionalCollection
    where Value == String
{
    // BidirectionalCollection
    
    public func index(before i: String.Index) -> String.Index
    {
        if value == nil { value = "" }
        return string.index(before: i)
    }
    
    // Collection
    
    public func index(after i: String.Index) -> String.Index
    {
        if value == nil { value = "" }
        return string.index(after: i)
    }
    
    public subscript(position: String.Index) -> String.Element
    {
        if value == nil { value = "" }
        return string[position]
    }
    
    public var startIndex: String.Index
    {
        if value == nil { value = "" }
        return string.startIndex
    }
    
    public var endIndex: String.Index
    {
        if value == nil { value = "" }
        return string.endIndex
    }
    
    public var indices: String.Indices
    {
        if value == nil { value = "" }
        return string.indices
    }
    
    public typealias Index = String.Index
    public typealias SubSequence = String.SubSequence
    public typealias Indices = String.Indices
    
    // Sequence
    
    public func makeIterator() -> String.Iterator
    {
        return string.makeIterator()
    }
    
    public typealias Element = String.Element
    public typealias Iterator = String.Iterator
    
    // TextOutputStream
    
    public func write(_ str: String)
    {
        if value == nil { value = "" }
        value?.write(str)
    }
    
    // CustomDebugStringConvertible & CustomStringConvertible
    
    public var debugDescription: String { return string }
    public var description: String { return string }
    
    // Non-Optional String
    
    var string: String
    {
        get { return value ?? ""}
        set { value = newValue }
    }
}
