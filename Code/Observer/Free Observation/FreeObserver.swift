public class FreeObserver: Observer
{
    public static let shared = FreeObserver()
    public let receiver = Receiver()
}
