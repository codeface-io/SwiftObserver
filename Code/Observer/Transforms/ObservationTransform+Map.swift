public extension ObservationTransform
{
    func map<Mapped>(_ map: @escaping (Message) -> Mapped,
                     receiveMapped: @escaping (Mapped, AnyAuthor) -> Void)
    {
        startObservation
        {
            message, author in
            
            receiveMapped(map(message), author)
        }
    }
    
    func map<Mapped>(_ map: @escaping (Message) -> Mapped,
                     receiveMapped: @escaping (Mapped) -> Void)
    {
        startObservation
        {
            message, _ in
            
            receiveMapped(map(message))
        }
    }
    
    func map<Mapped>(_ map: @escaping (Message) -> Mapped) -> ObservationTransform<Mapped>
    {
        ObservationTransform<Mapped>
        {
            receiveMapped in

            self.startObservation
            {
                message, author in
                
                receiveMapped(map(message), author)
            }
        }
    }
}
