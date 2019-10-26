public extension Mapping where MappedMessage: Equatable
{
    func select(_ default: MappedMessage) -> Mapping<O, Void>
    {
        filterMap(filter: { $0 == `default` }) { _ in }
    }
}

public extension Mapping
{
    func new<Value>() -> Mapping<O, Value>
        where MappedMessage == Change<Value>
    {
        map { $0.new }
    }
    
    func filter(_ keep: @escaping Filter) -> Mapping<O, MappedMessage>
    {
        filterMap(filter: keep) { $0 }
    }
    
    func unwrap<Wrapped>(_ default: Wrapped) -> Mapping<O, Wrapped>
        where MappedMessage == Wrapped?
    {
        map { $0 ?? `default` }
    }
    
    func map<ComposedMessage>(_ map: @escaping (MappedMessage) -> ComposedMessage) -> Mapping<O, ComposedMessage>
    {
        filterMap(filter: nil, map: map)
    }
}
