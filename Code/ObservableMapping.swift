public extension ObservableProtocol
{
    public func new<TargetUpdate>() -> ObservableMapping<Self, TargetUpdate> where UpdateType == Update<TargetUpdate>
    {
        return ObservableMapping(observable: self) { $0.new }
    }
    
    public func map<TargetUpdate>(_ mapping: @escaping (UpdateType) -> (TargetUpdate)) -> ObservableMapping<Self, TargetUpdate>
    {
        return ObservableMapping(observable: self, mapping: mapping)
    }
}

public class ObservableMapping<SourceObservable: ObservableProtocol,
    MappedUpdate>: ObservableProtocol
{
    init(observable: SourceObservable, mapping: @escaping Mapping)
    {
        self.observable = observable
        self.map = mapping
    }
    
    public func add(_ observer: AnyObject,
                    _ receive: @escaping UpdateReceiver)
    {
        observable.add(observer)
        {
            [weak self] in
            
            guard let me = self else { return }
            
            receive(me.map($0))
        }
    }
    
    public func remove(_ observer: AnyObject)
    {
        observable.remove(observer)
    }
    
    public func removeAllObservers()
    {
        observable.removeAllObservers()
    }
    
    public func removeNilObservers()
    {
        observable.removeNilObservers()
    }
    
    public var update: MappedUpdate { return map(observable.update) }
    
    private let map: Mapping
    let observable: SourceObservable
    
    typealias Mapping = (SourceObservable.UpdateType) -> (MappedUpdate)
    public typealias UpdateType = MappedUpdate
}
