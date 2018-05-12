public extension Observable
{
    public func new<MappedUpdate>() -> Mapping<Self, MappedUpdate>
        where UpdateType == Update<MappedUpdate>
    {
        return map { $0.new }
    }
    
    public func filter(_ keep: @escaping UpdateFilter) -> Mapping<Self, UpdateType>
    {
        return map(prefilter: keep) { $0 }
    }
    
    public func unwrap<Unwrapped>(_ defaultUpdate: Unwrapped) -> Mapping<Self, Unwrapped>
        where Self.UpdateType == Optional<Unwrapped>
    {
        return map(prefilter: { $0 != nil }) { $0 ?? defaultUpdate }
    }
    
    public func map<MappedUpdate>(prefilter: @escaping UpdateFilter = { _ in true },
                                  map: @escaping (UpdateType) -> MappedUpdate)
        -> Mapping<Self, MappedUpdate>
    {
        return Mapping(self,
                       latestMappedUpdate: map(latestUpdate),
                       prefilter: prefilter,
                       map: map)
    }
}

extension Mapping
{
    public func new<Value>() -> Mapping<SourceObservable, Value>
        where MappedUpdate == Update<Value>
    {
        return map { $0.new }
    }
    
    public func filter(_ keep: @escaping UpdateFilter)
        -> Mapping<SourceObservable, MappedUpdate>
    {
        return map(prefilter: keep) { $0 }
    }
    
    public func unwrap<Unwrapped>(_ defaultUpdate: Unwrapped)
        -> Mapping<SourceObservable, Unwrapped>
        where MappedUpdate == Optional<Unwrapped>
    {
        return map(prefilter: { $0 != nil }, map: { $0 ?? defaultUpdate })
    }
    
    public func map<MappedUpdate2>(
        prefilter: @escaping (MappedUpdate) -> Bool = { _ in true },
        map: @escaping (MappedUpdate) -> MappedUpdate2)
        -> Mapping<SourceObservable, MappedUpdate2>
    {
        let localMap = self.map
        let localPrefilter = self.prefilter
        
        return Mapping<SourceObservable, MappedUpdate2>(
            observable,
            latestMappedUpdate: map(latestUpdate),
            prefilter: { localPrefilter($0) && prefilter(localMap($0)) },
            map: { map(localMap($0)) })
    }
}

public class Mapping<SourceObservable: Observable, MappedUpdate>: Observable
{
    fileprivate init(_ observable: SourceObservable?,
                     latestMappedUpdate: MappedUpdate,
                     prefilter: @escaping SourceObservable.UpdateFilter = { _ in true },
                     map: @escaping Mapper)
    {
        self.observable = observable
        self.prefilter = prefilter
        self.map = map
        self.latestMappedUpdate = latestMappedUpdate
        
        if let observable = observable
        {
            startObserving(observable)
        }
    }
    
    private func receivedPrefiltered(_ update: SourceObservable.UpdateType)
    {
        latestMappedUpdate = map(update)
        send(latestMappedUpdate)
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
        if let latestOriginalUpdate = observable?.latestUpdate,
            prefilter(latestOriginalUpdate)
        {
            latestMappedUpdate = map(latestOriginalUpdate)
        }
        
        return latestMappedUpdate
    }
    
    private var latestMappedUpdate: MappedUpdate

    public weak var observable: SourceObservable?
    {
        didSet
        {
            guard let newObservable = observable,
                newObservable !== oldValue
            else
            {
                return
            }
            
            startObserving(newObservable)
        }
    }
    
    private func startObserving(_ observable: SourceObservable)
    {
        observable.add(self, filter: prefilter)
        {
            [weak self] update in
            
            self?.receivedPrefiltered(update)
        }
    }
    
    fileprivate let prefilter: SourceObservable.UpdateFilter
    
    fileprivate let map: Mapper
    typealias Mapper = (SourceObservable.UpdateType) -> MappedUpdate
}
