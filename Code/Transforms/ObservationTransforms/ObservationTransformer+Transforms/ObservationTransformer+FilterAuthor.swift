public extension ObservationTransformer
{
    func filterAuthor(_ keep: @escaping (AnyAuthor) -> Bool,
                      receiveFiltered: @escaping (Transformed, AnyAuthor) -> Void)
    {
        startObservation
        {
            message, author in

            if keep(author) { receiveFiltered(message, author) }
        }
    }
    
    func filterAuthor(_ keep: @escaping (AnyAuthor) -> Bool,
                      receiveFiltered: @escaping (Transformed) -> Void)
    {
        startObservation
        {
            message, author in

            if keep(author) { receiveFiltered(message) }
        }
    }
    
    func filterAuthor(_ keep: @escaping (AnyAuthor) -> Bool) -> ObservationTransformer<Transformed>
    {
        ObservationTransformer
        {
            receiveFiltered in

            self.startObservation
            {
                message, author in
                
                if keep(author) { receiveFiltered(message, author) }
            }
        }
    }
}
