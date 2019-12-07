public extension ObservationTransformer
{
    func filter(_ keep: @escaping (Transformed) -> Bool,
                receiveFiltered: @escaping (Transformed, AnyAuthor) -> Void)
    {
        startObservation
        {
            message, author in

            if keep(message) { receiveFiltered(message, author) }
        }
    }
    
    func filter(_ keep: @escaping (Transformed) -> Bool,
                receiveFiltered: @escaping (Transformed) -> Void)
    {
        startObservation
        {
            message, _ in

            if keep(message) { receiveFiltered(message) }
        }
    }
    
    func filter(_ keep: @escaping (Transformed) -> Bool) -> ObservationTransformer<Transformed>
    {
        ObservationTransformer
        {
            receiveFiltered in

            self.startObservation
            {
                message, author in
                
                if keep(message) { receiveFiltered(message, author) }
            }
        }
    }
}
