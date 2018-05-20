public extension Observable
{
    public func new<MappedUpdate>() -> Mapping<Self, MappedUpdate>
        where UpdateType == Update<MappedUpdate>
    {
        return map { $0.new }
    }
    
    public func change<MappedUpdate>() -> Mapping<Self, MappedUpdate>
        where UpdateType == Update<MappedUpdate>, MappedUpdate: Equatable
    {
        return map(prefilter: { $0.old != $0.new }) { $0.new }
    }
    
    public func change<MappedUpdate>() -> Mapping<Self, Optional<MappedUpdate>>
        where UpdateType == Update<Optional<MappedUpdate>>, MappedUpdate: Equatable
    {
        return map(prefilter: { $0.old != $0.new }) { $0.new }
    }
    
    public func filter(_ keep: @escaping UpdateFilter) -> Mapping<Self, UpdateType>
    {
        return map(prefilter: keep) { $0 }
    }
    
    public func unwrap<Unwrapped>(_ defaultUpdate: Unwrapped) -> Mapping<Self, Unwrapped>
        where Self.UpdateType == Optional<Unwrapped>
    {
        return map { $0 ?? defaultUpdate }
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

// MARK: -

extension Mapping
{
    public func new<Value>() -> Mapping<SourceObservable, Value>
        where MappedUpdate == Update<Value>
    {
        return map { $0.new }
    }
    
    public func change<Value>() -> Mapping<SourceObservable, Value>
        where MappedUpdate == Update<Value>, Value: Equatable
    {
        return map(prefilter: { $0.old != $0.new }) { $0.new }
    }
    
    public func change<Value>() -> Mapping<SourceObservable, Optional<Value>>
        where MappedUpdate == Update<Optional<Value>>, Value: Equatable
    {
        return map(prefilter: { $0.old != $0.new }) { $0.new }
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
        return map { $0 ?? defaultUpdate }
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

// MARK: -

public class Mapping<SourceObservable: Observable, MappedUpdate>: Observable
{
    // MARK: Life Cycle
    
    fileprivate init(_ observable: SourceObservable?,
                     latestMappedUpdate: MappedUpdate,
                     prefilter: @escaping SourceObservable.UpdateFilter = { _ in true },
                     map: @escaping Mapper)
    {
        self.observable = observable
        self.prefilter = prefilter
        self.map = map
        self.latestMappedUpdate = latestMappedUpdate
        
        observe(observable)
    }
    
    deinit { observable?.remove(self) }
    
    // MARK: Observable
    
    public var latestUpdate: MappedUpdate
    {
        if let latestOriginalUpdate = observable?.latestUpdate,
            prefilter(latestOriginalUpdate)
        {
            latestMappedUpdate = map(latestOriginalUpdate)
        }
        
        return latestMappedUpdate
    }

    public weak var observable: SourceObservable?
    {
        didSet
        {
            guard oldValue !== observable else { return }
            
            didSwitchObservable(from: oldValue, to: observable)
        }
    }
    
    
    private func didSwitchObservable(from old: SourceObservable?,
                                     to new: SourceObservable?)
    {
        old?.remove(self)
        observe(new)
        new?.send()
    }
    
    private func observe(_ observable: SourceObservable?)
    {
        guard let observable = observable else { return }
        
        observable.add(self, filter: prefilter)
        {
            [weak self] update in
            
            self?.receivedPrefiltered(update)
        }
    }
    
    private func receivedPrefiltered(_ update: SourceObservable.UpdateType)
    {
        latestMappedUpdate = map(update)
        send(latestMappedUpdate)
    }
    
    private var latestMappedUpdate: MappedUpdate
    
    // MARK: Map Functions
    
    fileprivate let prefilter: SourceObservable.UpdateFilter
    
    fileprivate let map: Mapper
    typealias Mapper = (SourceObservable.UpdateType) -> MappedUpdate
}
