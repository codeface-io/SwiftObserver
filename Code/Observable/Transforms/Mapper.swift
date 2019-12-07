public class Mapper<O: Observable, Mapped>: Observable, Observer
{
    public init(_ observable: O,
                _ map: @escaping (O.Message) -> Mapped)
    {
        self.observable = observable
        self.map = map
        
        observe(observable)
        {
            [weak self] in
            
            self?.send(map($0), author: $1)
        }
    }
    
    internal let map: (O.Message) -> Mapped
    internal let observable: O
    
    public let messenger = Messenger<Mapped>()
    public let receiver = Receiver()
}
