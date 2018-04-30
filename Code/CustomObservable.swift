public typealias Observable = CustomObservable

public extension CustomObservable
{
    func add(_ observer: AnyObject,
             _ receive: @escaping UpdateReceiver)
    {
        ObservationService.add(observer, of: self)
        {
            guard let update = $0 as? UpdateType else
            {
                fatalError("Impossible error: could not cast update type received from observation center")
            }
            
            receive(update)
        }
    }
    
    func send(_ update: UpdateType)
    {
        ObservationService.send(update, toObserversOf: self)
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

public protocol CustomObservable: UpdateSender {}
