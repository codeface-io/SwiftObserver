// TODO: document as pattern: if no specific observer is available/responsible, but a specific observation (closure) shall be stopped manually like with a cancellable... anonymous observer doesn't work because that is used by other clients as well and might observe the observable with other closures already that we don't want to stop ... then a free observer itself can serve as a "cancellable" reference to a specific observation. as long as we hold on to it, we can stop the observation ...

public class FreeObserver: Observer
{
    public static let shared = FreeObserver()

//    init() { print("🥚") }
//    
//    deinit { print("💀") }
    
    public let receiver = Receiver()
}
