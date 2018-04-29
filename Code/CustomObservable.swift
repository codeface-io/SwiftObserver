public typealias Observable = CustomObservable

public extension CustomObservable
{
    func add(_ observer: AnyObject,
             _ handleUpdate: @escaping UpdateHandler)
    {
        ObservationService.add(observer, of: self)
        {
            guard let update = $0 as? UpdateType else
            {
                fatalError("Impossible error: could not cast update type received from observation center")
            }
            
            handleUpdate(update)
        }
    }
    
    func updateObservers(_ update: UpdateType)
    {
        ObservationService.updateObservers(of: self, with: update)
    }
    
    func remove(_ observer: AnyObject)
    {
        ObservationService.remove(observer, of: self)
    }
    
    func removeAllObservers()
    {
        ObservationService.removeAllObservers(of: self)
    }
    
    func removeNilObservers()
    {
        ObservationService.removeNilObservers(of: self)
    }
}

public protocol CustomObservable: ObserverUpdater {}
