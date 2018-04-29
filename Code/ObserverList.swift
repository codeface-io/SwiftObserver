 import SwiftyToolz
 
 class ObserverList<UpdateType>
 {
    func add(_ observer: AnyObject,
             _ handleUpdate: @escaping (UpdateType) -> Void)
    {
        let observerInfo = ObserverInfo(observer: observer,
                                        handleUpdate: handleUpdate)
        
        observers[hash(observer)] = observerInfo
    }
    
    func remove(_ observer: AnyObject)
    {
        observers[hash(observer)] = nil
    }
    
    func removeNilObservers()
    {
        observers.remove { $0.observer == nil }
    }
    
    func removeAll()
    {
        observers.removeAll()
    }
    
    var isEmpty: Bool { return observers.isEmpty }
    
    func update(_ update: UpdateType)
    {
        for observer in observers.values
        {
            observer.handleUpdate(update)
        }
    }
    
    private var observers = [HashValue: ObserverInfo<UpdateType>]()
 }
 
 fileprivate class ObserverInfo<UpdateType>
 {
    init(observer: AnyObject, handleUpdate: @escaping (UpdateType) -> ())
    {
        self.observer = observer
        self.handleUpdate = handleUpdate
    }
    
    weak var observer: AnyObject?
    let handleUpdate: (UpdateType) -> ()
 }
