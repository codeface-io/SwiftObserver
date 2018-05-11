 import SwiftyToolz
 
 class ObserverList<Update>
 {
    func add(_ observer: AnyObject,
             receive: @escaping (Update) -> Void)
    {
        let observerInfo = ObserverInfo(observer: observer, receive: receive)
        
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
    
    func receive(_ update: Update)
    {
        for observer in observers.values
        {
            observer.receive(update)
        }
    }
    
    private var observers = [HashValue: ObserverInfo<Update>]()
 }
 
 fileprivate class ObserverInfo<Update>
 {
    init(observer: AnyObject, receive: @escaping (Update) -> Void)
    {
        self.observer = observer
        self.receive = receive
    }
    
    weak var observer: AnyObject?
    let receive: (Update) -> Void
 }
