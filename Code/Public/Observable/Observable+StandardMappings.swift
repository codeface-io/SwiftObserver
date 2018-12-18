public extension Observable where Message: Equatable
{
    public func select(_ default: Message) -> Mapping<Self, Void>
    {
        return Mapping(self, filter: { $0 == `default` }) { _ in }
    }
}

public extension Observable
{
    public func new<MappedMessage>() -> Mapping<Self, MappedMessage>
        where Message == Change<MappedMessage>
    {
        return map { $0.new }
    }
    
    public func filter(_ keep: @escaping Filter) -> Mapping<Self, Message>
    {
        return Mapping(self, filter: keep) { $0 }
    }
    
    public func unwrap<Unwrapped>(_ default: Unwrapped) -> Mapping<Self, Unwrapped>
        where Self.Message == Optional<Unwrapped>
    {
        return map { $0 ?? `default` }
    }
    
    public func map<MappedMessage>(map: @escaping (Message) -> MappedMessage) -> Mapping<Self, MappedMessage>
    {
        return Mapping(self, map: map)
    }
}
