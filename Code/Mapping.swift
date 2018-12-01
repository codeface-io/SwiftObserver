public class Mapping<O: Observable, MappedUpdate>: Observable
{
    // MARK: Life Cycle
    
    init(_ observable: O?,
         latestMappedUpdate: MappedUpdate,
         prefilter: O.UpdateFilter? = nil,
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
            prefilter?(latestOriginalUpdate) ?? true
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
    
    let prefilter: O.UpdateFilter?
    
    let map: Mapper
    typealias Mapper = (O.UpdateType) -> MappedUpdate
}
