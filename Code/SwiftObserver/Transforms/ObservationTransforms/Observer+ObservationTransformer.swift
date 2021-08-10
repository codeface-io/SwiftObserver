public extension Observer
{
    func observe<O: ObservableObject>(_ observable: O) -> ObservationTransformer<O.Message>
    {
        ObservationTransformer
        {
            receive in self.observe(observable, receive: receive)
        }
    }
}
