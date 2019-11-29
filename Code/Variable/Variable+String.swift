// MARK: - Concatenating

infix operator +: AdditionPrecedence

public func +<S1: StringValue, S2: StringValue>(str1: S1, str2: S2) -> String
{
    return str1.string + str2.string
}

// MARK: - Protocol Conformances

extension Var: CustomStringConvertible
    where Value: CustomStringConvertible
{
    public var description: String
    {
        value.description
    }
}

extension Var: CustomDebugStringConvertible
    where Value: CustomDebugStringConvertible
{
    public var debugDescription: String
    {
        value.debugDescription
    }
}

extension Var: StringValue,
    TextOutputStream,
    Sequence,
    Collection,
    BidirectionalCollection
    where Value: StringValue
{
    // BidirectionalCollection
    
    public func index(before i: String.Index) -> String.Index
    {
        string.index(before: i)
    }
    
    // Collection
    
    public func index(after i: String.Index) -> String.Index
    {
        string.index(after: i)
    }
    
    public subscript(position: String.Index) -> String.Element
    {
        string[position]
    }
    
    public var startIndex: String.Index
    {
        string.startIndex
    }
    
    public var endIndex: String.Index
    {
        string.endIndex
    }
    
    public var indices: String.Indices
    {
        string.indices
    }
    
    public typealias Index = String.Index
    public typealias SubSequence = String.SubSequence
    public typealias Indices = String.Indices
    
    // Sequence
    
    public func makeIterator() -> String.Iterator
    {
        string.makeIterator()
    }
    
    public typealias Element = String.Element
    public typealias Iterator = String.Iterator
    
    // TextOutputStream
    
    public func write(_ str: String)
    {
        string.write(str)
    }
    
    // StringValue
    
    public var string: String
    {
        get { value.string }
        set { value.string = newValue }
    }
}

extension String: StringValue
{
    public var string: String
    {
        get { self }
        set { self = newValue }
    }
}

extension Optional: StringValue where Wrapped: StringValue
{
    public var string: String
    {
        get { self?.string ?? "" }
        set { self?.string = newValue }
    }
}

public protocol StringValue
{
    var string: String { get set }
}
