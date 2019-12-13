public extension ObservationTransformer
{
    func map<Mapped>(_ map: @escaping (Transformed) -> Mapped,
                     receiveMapped: @escaping (Mapped, AnyAuthor) -> Void)
    {
        startObservation
        {
            message, author in
            
            receiveMapped(map(message), author)
        }
    }
    
    func map<Mapped>(_ map: @escaping (Transformed) -> Mapped,
                     receiveMapped: @escaping (Mapped) -> Void)
    {
        startObservation
        {
            message, _ in
            
            receiveMapped(map(message))
        }
    }
    
    func map<Mapped>(_ map: @escaping (Transformed) -> Mapped) -> ObservationTransformer<Mapped>
    {
        ObservationTransformer<Mapped>
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
