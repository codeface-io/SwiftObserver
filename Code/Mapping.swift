public extension Observable
{
    public func new<TargetUpdate>() -> Mapping<Self, TargetUpdate>
        where UpdateType == Update<TargetUpdate>
    {
        return Mapping(observable: self) { $0.new }
    }
    
    public func map<TargetUpdate>(_ mapping: @escaping (UpdateType) -> (TargetUpdate))
        -> Mapping<Self, TargetUpdate>
    {
        return Mapping(observable: self, mapping: mapping)
    }
}

public class Mapping<SourceObservable: Observable, MappedUpdate>: Observable
{
    init(observable: SourceObservable, mapping: @escaping Mapping)
    {
        self.observable = observable
        self.map = mapping
        
        latestMappedUpdate = map(observable.latestUpdate)
        
        startObserving(observable)
    }
    
    func startObserving(_ observable: SourceObservable)
    {
        observable.add(self)
        {
            [weak self] update in
            
            guard let me = self else { return }
            
            me.send(me.map(update))
        }
    }
    
    deinit
    {
        if let observable = observable
        {
            ObservationService.remove(self, from: observable)
        }
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
