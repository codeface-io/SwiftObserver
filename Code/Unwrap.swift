public extension ObservableProtocol
{
    public func unwrap<Unwrapped>(_ defaultUpdate: Unwrapped) -> Unwrap<Self, Unwrapped>
    {
        return Unwrap(observable: self,
                                defaultUpdate: defaultUpdate)
    }
}

public class Unwrap<SourceObservable: ObservableProtocol, Unwrapped>: Mapping<SourceObservable, Unwrapped> where SourceObservable.UpdateType == Optional<Unwrapped>
{
    init(observable: SourceObservable, defaultUpdate: Unwrapped)
    {
        super.init(observable: observable) { $0 ?? defaultUpdate }
    }
    
    public override func add(_ observer: AnyObject,
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
