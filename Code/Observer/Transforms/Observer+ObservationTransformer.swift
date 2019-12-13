public extension Observer
{
    func observe<O: Observable>(_ observable: O) -> ObservationTransformer<O.Message>
    {
        ObservationTransformer
        {
            receive in self.observe(observable, receive: receive)
        }
    }
}
