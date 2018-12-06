// MARK: - Concatenating

infix operator +: AdditionPrecedence

public func + (strVar: Var<String>?, str: String?) -> String
{
    return (strVar?.string ?? "") + (str ?? "")
}

public func + (str: String?, strVar: Var<String>?) -> String
{
    return (str ?? "") + (strVar?.string ?? "")
}

public func + (strVar1: Var<String>?, strVar2: Var<String>?) -> String
{
    return (strVar1?.string ?? "") + (strVar2?.string ?? "")
}

infix operator +=: AssignmentPrecedence

public func += (strVar: Var<String>?, str: String?)
{
    strVar?.string += (str ?? "")
}

public func += (str: inout String, strVar: Var<String>?)
{
    str += (strVar?.string ?? "")
}

public func += (strVar1: Var<String>?, strVar2: Var<String>?)
{
    strVar1?.string += (strVar2?.string ?? "")
}

extension Var: CustomStringConvertible
    where Value: CustomStringConvertible
{
    public var description: String
    {
        return value?.description ?? ""
    }
}

extension Var: CustomDebugStringConvertible
    where Value: CustomDebugStringConvertible
{
    public var debugDescription: String
    {
        return value?.debugDescription ?? ""
    }
}

// MARK: - Protocol Conformances

extension Var:
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
    
    // Non-Optional String
    
    var string: String
    {
        get { return value ?? ""}
        set { value = newValue }
    }
}
