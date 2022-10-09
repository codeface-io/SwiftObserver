public extension ObservableObject
{
    /**
     End all observations of this object that were started by the given ``Observer``
     */
    func stopBeingObserved(by observer: Observer)
    {
        messenger.disconnectReceiver(with: ReceiverKey(observer.receiver))
    }
}
