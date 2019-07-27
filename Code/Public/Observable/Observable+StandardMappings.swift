public extension Observable where Message: Equatable
{
    func select(_ default: Message) -> Mapping<Self, Void>
    {
        return Mapping(self, filter: { $0 == `default` }) { _ in }
    }
}

public extension Observable
{
    func new<MappedMessage>() -> Mapping<Self, MappedMessage>
        where Message == Change<MappedMessage>
    {
        return map { $0.new }
    }
    
    func filter(_ keep: @escaping Filter) -> Mapping<Self, Message>
    {
        return Mapping(self, filter: keep) { $0 }
    }
    
    func unwrap<Wrapped>(_ default: Wrapped) -> Mapping<Self, Wrapped>
        where Self.Message == Optional<Wrapped>
    {
        return map { $0 ?? `default` }
    }
    
    func map<MappedMessage>(map: @escaping (Message) -> MappedMessage) -> Mapping<Self, MappedMessage>
    {
        return Mapping(self, map: map)
    }
}
