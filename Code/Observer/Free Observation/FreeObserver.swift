public class FreeObserver: Observer
{
    public init() {}
    public static let shared = FreeObserver()
    public let receiver = Receiver()
}
