
public extension Observer
{
    func observe<O: Observable>(_ observable: O) -> ObservationTransform<O.Message>
    {
        ObservationTransform
        {
            receive in self.observe(observable, receive: receive)
        }
    }
}


