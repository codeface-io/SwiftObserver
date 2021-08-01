extension Observable
{
    func stopBeingObserved(by observer: Observer)
    {
        messenger.disconnectReceiver(with: ReceiverKey(observer.receiver))
    }
    
    func stopBeingObserved()
    {
        messenger.disconnectAllReceivers()
    }
}
