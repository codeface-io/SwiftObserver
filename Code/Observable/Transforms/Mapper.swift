public class Mapper<O: Observable, Mapped>: Messenger<Mapped>, Observer
{
    public init(_ origin: O,
                _ map: @escaping (O.Message) -> Mapped)
    {
        self.origin = origin
        self.map = map
        super.init()
        observe(origin: origin)
    }
    
    public var origin: O
    {
        willSet
        {
            stopObserving(origin)
            observe(origin: newValue)
        }
    }
    
    private func observe(origin: O)
    {
        observe(origin)
        {
            [weak self] message, author in
            
            guard let self = self else { return }
            
            self.send(self.map(message), from: author)
        }
    }
    
    internal let map: (O.Message) -> Mapped
    
    public let receiver = Receiver()
}
