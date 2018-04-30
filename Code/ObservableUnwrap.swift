public extension ObservableProtocol
{
    public func unwrap<Unwrapped>(_ defaultUpdate: Unwrapped) -> ObservableUnwrap<Self, Unwrapped>
    {
        return ObservableUnwrap(observable: self,
                                defaultUpdate: defaultUpdate)
    }
}

public class ObservableUnwrap<SourceObservable: ObservableProtocol, Unwrapped>: ObservableMapping<SourceObservable, Unwrapped> where SourceObservable.UpdateType == Optional<Unwrapped>
{
    init(observable: SourceObservable, defaultUpdate: Unwrapped)
    {
        super.init(observable: observable) { $0 ?? defaultUpdate }
    }
    
    public override func add(_ observer: AnyObject,
                             _ receive: @escaping UpdateReceiver)
    {
        observable.add(observer)
        {
            if let unwrapped = $0
            {
                receive(unwrapped)
            }
        }
    }
}
