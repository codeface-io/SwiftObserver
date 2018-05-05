public extension ObservableProtocol
{
    public func unwrap<Unwrapped>(_ defaultUpdate: Unwrapped) -> Mapping<Self, Unwrapped>
        where Self.UpdateType == Optional<Unwrapped>
    {
        return Unwrap(observable: self, defaultUpdate: defaultUpdate)
    }
}

class Unwrap<SourceObservable: ObservableProtocol, Unwrapped>: Mapping<SourceObservable, Unwrapped> where SourceObservable.UpdateType == Optional<Unwrapped>
{
    init(observable: SourceObservable, defaultUpdate: Unwrapped)
    {
        super.init(observable: observable) { $0 ?? defaultUpdate }
    }
    
    override func add(_ observer: AnyObject,
                      _ receive: @escaping UpdateReceiver)
    {
        observable?.add(observer)
        {
            if let unwrapped = $0
            {
                receive(unwrapped)
            }
        }
    }
}
