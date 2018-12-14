public extension Mapping where MappedUpdate: Equatable
{
    public func select(_ default: MappedUpdate) -> Mapping<O, Void>
    {
        return filterMap(filter: { $0 == `default` }) { _ in }
    }
}

public extension Mapping
{
    public func new<Value>() -> Mapping<O, Value>
        where MappedUpdate == Update<Value>
    {
        return map { $0.new }
    }
    
    public func filter(_ keep: @escaping UpdateFilter) -> Mapping<O, MappedUpdate>
    {
        return filterMap(filter: keep) { $0 }
    }
    
    public func unwrap<Unwrapped>(_ default: Unwrapped) -> Mapping<O, Unwrapped>
        where MappedUpdate == Optional<Unwrapped>
    {
        return map { $0 ?? `default` }
    }
    
    public func map<ComposedUpdate>(_ map: @escaping (MappedUpdate) -> ComposedUpdate) -> Mapping<O, ComposedUpdate>
    {
        return filterMap(filter: nil, map: map)
    }
}
