public extension Observable where Message: Equatable
{
    func select(_ default: Message) -> Mapping<Self, Void>
    {
        Mapping(self, filter: { $0 == `default` }) { _ in }
    }
}

public extension Observable
{
    func new<MappedMessage>() -> Mapping<Self, MappedMessage>
        where Message == Change<MappedMessage>
    {
        map { $0.new }
    }
    
    func filter(_ keep: @escaping Filter) -> Mapping<Self, Message>
    {
        Mapping(self, filter: keep) { $0 }
    }
    
    func unwrap<Wrapped>(_ default: Wrapped) -> Mapping<Self, Wrapped>
        where Self.Message == Wrapped?
    {
        map { $0 ?? `default` }
    }
    
    func unwrap<Wrapped>() -> Mapping<Self, Wrapped>
        where Self.Message == Wrapped?
    {
        Mapping(self, filter: {  $0 != nil }) { $0! }
    }
    
    func map<MappedMessage>(map: @escaping (Message) -> MappedMessage) -> Mapping<Self, MappedMessage>
    {
        Mapping(self, map: map)
    }
}
