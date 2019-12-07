public extension ObservationStarter
{
    func filter(_ keep: @escaping (Message) -> Bool,
                receiveFiltered: @escaping (Message, AnyAuthor) -> Void)
    {
        startObservation
        {
            message, author in

            if keep(message) { receiveFiltered(message, author) }
        }
    }
    
    func filter(_ keep: @escaping (Message) -> Bool,
                receiveFiltered: @escaping (Message) -> Void)
    {
        startObservation
        {
            message, _ in

            if keep(message) { receiveFiltered(message) }
        }
    }
    
    func filter(_ keep: @escaping (Message) -> Bool) -> ObservationStarter<Message>
    {
        ObservationStarter
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
