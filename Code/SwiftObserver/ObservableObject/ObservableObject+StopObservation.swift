public extension ObservableObject
{
    func stopBeingObserved()
    {
        messenger.disconnectAllReceivers()
    }
}
