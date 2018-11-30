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
    public func new<Value>() -> Mapping<O, Value>
        where MappedUpdate == Update<Value>
    {
        return map { $0.new }
    }
    
    public func filter(_ keep: @escaping UpdateFilter) -> Mapping<O, MappedUpdate>
    {
        return map(prefilter: keep) { $0 }
    }
    
    public func unwrap<Unwrapped>(_ defaultUpdate: Unwrapped) -> Mapping<O, Unwrapped>
        where MappedUpdate == Optional<Unwrapped>
    {
        return map { $0 ?? defaultUpdate }
    }
    
    public func map<CombinedUpdate>(prefilter: @escaping Postfilter = { _ in true },
                                    map: @escaping (MappedUpdate) -> CombinedUpdate) -> Mapping<O, CombinedUpdate>
    {
        let myMap = self.map
        let myPrefilter = self.prefilter
        
        let combinedPrefilter: O.UpdateFilter =
        {
            myPrefilter($0) && prefilter(myMap($0))
        }
        
        let combinedMap: (O.UpdateType) -> CombinedUpdate =
        {
            map(myMap($0))
        }
        
        return Mapping<O, CombinedUpdate>(observable,
                                          latestMappedUpdate: map(latestUpdate),
                                          prefilter: combinedPrefilter,
                                          map: combinedMap)
    }
    
    public typealias Postfilter = (MappedUpdate) -> Bool
}

// MARK: -

public class Mapping<O: Observable, MappedUpdate>: Observable
{
    // MARK: Life Cycle
    
    fileprivate init(_ observable: O?,
                     latestMappedUpdate: MappedUpdate,
                     prefilter: @escaping O.UpdateFilter = { _ in true },
                     map: @escaping Mapper)
    {
        self.observable = observable
        self.prefilter = prefilter
        self.map = map
        self.latestMappedUpdate = latestMappedUpdate
        
        observe(observable)
    }
    
    deinit
    {
        observable?.remove(self)
        removeObservers()
    }
    
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

    public weak var observable: O?
    {
        didSet
        {
            guard oldValue !== observable else { return }
            
            didSwitchObservable(from: oldValue, to: observable)
        }
    }
    
    
    private func didSwitchObservable(from old: O?,
                                     to new: O?)
    {
        old?.remove(self)
        observe(new)
        send()
    }
    
    private func observe(_ observable: O?)
    {
        guard let observable = observable else { return }
        
        observable.add(self, filter: prefilter)
        {
            [weak self] update in
            
            self?.receivedPrefiltered(update)
        }
    }
    
    private func receivedPrefiltered(_ update: O.UpdateType)
    {
        latestMappedUpdate = map(update)
        send(latestMappedUpdate)
    }
    
    private var latestMappedUpdate: MappedUpdate
    
    // MARK: Map Functions
    
    fileprivate let prefilter: O.UpdateFilter
    
    fileprivate let map: Mapper
    typealias Mapper = (O.UpdateType) -> MappedUpdate
}
