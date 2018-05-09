public extension Observable
{
    public func unwrap<Unwrapped>(_ defaultUpdate: Unwrapped) -> Mapping<Self, Unwrapped>
        where Self.UpdateType == Optional<Unwrapped>
    {
        return Unwrap(observable: self, defaultUpdate: defaultUpdate)
    }
}

class Unwrap<SourceObservable: Observable, Unwrapped>: Mapping<SourceObservable, Unwrapped> where SourceObservable.UpdateType == Optional<Unwrapped>
{
    init(observable: SourceObservable, defaultUpdate: Unwrapped)
    {
        super.init(observable: observable) { $0 ?? defaultUpdate }
    }
    
    override func startObserving(_ observable: SourceObservable)
    {
        observable.add(self)
        {
            [weak self] update in
            
            guard let me = self else { return }
            
            if let update = update
            {
                me.send(update)
            }
        }
    }
}
