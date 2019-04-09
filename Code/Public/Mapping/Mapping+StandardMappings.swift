public extension Mapping where MappedMessage: Equatable
{
    func select(_ default: MappedMessage) -> Mapping<O, Void>
    {
        return filterMap(filter: { $0 == `default` }) { _ in }
    }
}

public extension Mapping
{
    func new<Value>() -> Mapping<O, Value>
        where MappedMessage == Change<Value>
    {
        return map { $0.new }
    }
    
    func filter(_ keep: @escaping Filter) -> Mapping<O, MappedMessage>
    {
        return filterMap(filter: keep) { $0 }
    }
    
    func unwrap<Unwrapped>(_ default: Unwrapped) -> Mapping<O, Unwrapped>
        where MappedMessage == Optional<Unwrapped>
    {
        return map { $0 ?? `default` }
    }
    
    func map<ComposedMessage>(_ map: @escaping (MappedMessage) -> ComposedMessage) -> Mapping<O, ComposedMessage>
    {
        return filterMap(filter: nil, map: map)
    }
}
