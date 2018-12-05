public class Mapping<O: Observable, MappedUpdate>: Observable
{
    // MARK: - Life Cycle
    
    init(_ source: O, prefilter: O.UpdateFilter? = nil, map: @escaping Mapper)
    {
        self.source = source
        self.prefilter = prefilter
        self.map = map
        
        observe(source: source)
    }
    
    deinit
    {
        source.remove(self)
        removeObservers()
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
            
            if prefilter?(sourceLatestUpdate) ?? true
            {
                send(map(sourceLatestUpdate))
            }
        }
    }
    
    private func observe(source: O)
    {
        source.add(self, filter: prefilter)
        {
            [weak self] update in
            
            guard let self = self else { return }
            
            self.send(self.map(update))
        }
    }
    
    // MARK: - Closures
    
    public let prefilter: O.UpdateFilter?
    let map: Mapper
    
    public typealias Mapper = (O.UpdateType) -> MappedUpdate
}
