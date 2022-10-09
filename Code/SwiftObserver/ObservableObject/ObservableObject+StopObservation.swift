public extension ObservableObject
{
    /**
     Ends all observations by all ``Observer``s
     */
    func stopBeingObserved()
    {
        messenger.disconnectAllReceivers()
    }
}
