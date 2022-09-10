public extension ObservableObject
{
    func stopBeingObserved(by observer: Observer)
    {
        messenger.disconnectReceiver(with: ReceiverKey(observer.receiver))
    }
}
