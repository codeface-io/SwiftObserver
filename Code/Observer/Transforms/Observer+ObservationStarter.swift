public extension Observer
{
    func observe<O: Observable>(_ observable: O) -> ObservationStarter<O.Message>
    {
        ObservationStarter
        {
            receive in self.observe(observable, receive: receive)
        }
    }
}
