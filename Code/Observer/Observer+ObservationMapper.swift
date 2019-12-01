public extension Observer
{
    func observe<O>(_ observable: O) -> ObservationMapper<O, O.Message>
    {
        ObservationMapper(observer: self,
                          observable: observable,
                          map: { $0 },
                          filter: nil)
    }
}

public struct ObservationMapper<O: Observable, T>
{
    public func receive(_ receive: @escaping (T, AnyAuthor) -> Void)
    {
        let localMap = self.map
        let localFilter = self.filter
        
        observable.add(observer)
        {
            if localFilter?($0) ?? true { receive(localMap($0), $1) }
        }
    }
    
    public func receive(_ receive: @escaping (T) -> Void)
    {
        let localMap = self.map
        let localFilter = self.filter
        
        observable.add(observer)
        {
            if localFilter?($0) ?? true { receive(localMap($0)) }
        }
    }

    let observer: AnyReceiver
    let observable: O
    let map: (O.Message) -> T
    let filter: ((O.Message) -> Bool)?
}
