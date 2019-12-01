public class Mapping<O: Observable, MappedMessage>: Observable
{
    // MARK: - Life Cycle
    
    init(_ source: O, filter: O.Filter? = nil, map: @escaping Mapper)
    {
        self.source = source
        self.filter = filter
        self.map = map
        
        observe(source: source)
    }
    
    deinit { source.remove(self) }
    
    // MARK: - Chain Mappings
    
    func filterMap<ComposedMessage>(filter: ((MappedMessage) -> Bool)? = nil,
                                    map: @escaping (MappedMessage) -> ComposedMessage) -> Mapping<O, ComposedMessage>
    {
        let localMap = self.map
        let localFilter = self.filter
        
        let addedFilter: ((O.Message) -> Bool)? =
        {
            guard let prefilter = filter else { return nil }
            return compose(localMap, prefilter)
        }()
        
        let composedFilter: ((O.Message) -> Bool)? =
        {
            guard let addedFilter = addedFilter else { return nil }
            return combineFilters(localFilter, addedFilter)
        }()
        
        return Mapping<O, ComposedMessage>(source,
                                           filter: composedFilter,
                                           map: compose(localMap, map))
    }
    
    // MARK: - Observable

    public var source: O
    {
        didSet
        {
            guard oldValue !== source else { return }
            
            oldValue.remove(self)
            observe(source: source)
        }
    }
    
    private func observe(source: O)
    {
        source.add(self)
        {
            [weak self] message, sender in
            
            guard let self = self else { return }
            
            if self.filter?(message) ?? true
            {
                self.send(self.map(message), sender: sender)
            }
        }
    }
    
    // MARK: - Closures
    
    public let filter: O.Filter?
    let map: Mapper
    
    typealias Mapper = (O.Message) -> MappedMessage
    
    // MARK: - Observable
    
    public let messenger = Messenger<MappedMessage>()
}

public extension Observable
{
    typealias Filter = (Message) -> Bool
}
