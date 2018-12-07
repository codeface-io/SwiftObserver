public class Mapping<O: Observable, MappedUpdate>: Observable
{
    // MARK: - Life Cycle
    
    init(_ source: O, filter: O.UpdateFilter? = nil, map: @escaping Mapper)
    {
        self.source = source
        self.filter = filter
        self.map = map
        
        observe(source: source)
    }
    
    deinit
    {
        source.remove(self)
        removeObservers()
    }
    
    // MARK: - Chain Mappings
    
    func filterMap<ComposedUpdate>(filter: ((MappedUpdate) -> Bool)? = nil,
                                   map: @escaping (MappedUpdate) -> ComposedUpdate) -> Mapping<O, ComposedUpdate>
    {
        let localMap = self.map
        let localFilter = self.filter
        
        let addedFilter: ((O.UpdateType) -> Bool)? =
        {
            guard let prefilter = filter else { return nil }
            
            return compose(localMap, prefilter)
        }()
        
        let composedFilter = combineFilters(localFilter, addedFilter)
        
        return Mapping<O, ComposedUpdate>(source,
                                          filter: composedFilter,
                                          map: compose(localMap, map))
    }
    
    // MARK: - Observable
    
    public var latestUpdate: MappedUpdate
    {
        return map(source.latestUpdate)
    }

    public var source: O
    {
        didSet
        {
            guard oldValue !== source else { return }
            
            oldValue.remove(self)
            observe(source: source)
            
            let sourceLatestUpdate = source.latestUpdate
            
            if filter?(sourceLatestUpdate) ?? true
            {
                send(map(sourceLatestUpdate))
            }
        }
    }
    
    private func observe(source: O)
    {
        source.add(self)
        {
            [weak self] update in
            
            guard let self = self else { return }
            
            if self.filter?(update) ?? true
            {
                self.send(self.map(update))
            }
        }
    }
    
    // MARK: - Closures
    
    public let filter: O.UpdateFilter?
    let map: Mapper
    
    typealias Mapper = (O.UpdateType) -> MappedUpdate
}
