public extension ObservableProtocol
{
    public func new<TargetUpdate>() -> Mapping<Self, TargetUpdate> where UpdateType == Update<TargetUpdate>
    {
        return Mapping(observable: self) { $0.new }
    }
    
    public func map<TargetUpdate>(_ mapping: @escaping (UpdateType) -> (TargetUpdate)) -> Mapping<Self, TargetUpdate>
    {
        return Mapping(observable: self, mapping: mapping)
    }
}

public class Mapping<SourceObservable: ObservableProtocol,
    MappedUpdate>: ObservableProtocol
{
    init(observable: SourceObservable, mapping: @escaping Mapping)
    {
        self.observable = observable
        self.map = mapping
        
        latestMappedUpdate = map(observable.latestUpdate)
    }
    
    public func add(_ observer: AnyObject,
                    _ receive: @escaping UpdateReceiver)
    {
        observable?.add(observer)
        {
            [weak self] in
            
            guard let me = self else { return }
            
            receive(me.map($0))
        }
    }
    
    public func remove(_ observer: AnyObject)
    {
        observable?.remove(observer)
    }
    
    public func removeAllObservers()
    {
        observable?.removeAllObservers()
    }
    
    public func removeNilObservers()
    {
        observable?.removeNilObservers()
    }
    
    public var latestUpdate: MappedUpdate
    {
        if let observable = observable
        {
            latestMappedUpdate = map(observable.latestUpdate)
        }
        
        return latestMappedUpdate
    }
    
    private var latestMappedUpdate: MappedUpdate

    public var hasObservable: Bool { return observable != nil }
    weak var observable: SourceObservable?
    
    private let map: Mapping
    typealias Mapping = (SourceObservable.UpdateType) -> (MappedUpdate)
    
    public typealias UpdateType = MappedUpdate
}
