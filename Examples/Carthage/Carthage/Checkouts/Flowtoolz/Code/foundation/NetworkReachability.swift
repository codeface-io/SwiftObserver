import ReachabilitySwift
import Foundation

let networkReachability = NetworkReachability()

class NetworkReachability
{
    fileprivate init() {}
    
    var isReachable = false
    
    func setup()
    {
        guard let reachability = reachabilityObject else
        {
            print("Creating Reachability Object failed")
            return
        }
        
        reachability.whenReachable =
        {
            reachability in
            
            DispatchQueue.main.async
            {
                self.isReachable = true
            }
        }
        
        reachability.whenUnreachable =
        {
            reachability in
            
            DispatchQueue.main.async
            {
                self.isReachable = false
            }
        }
        
        do
        {
            try reachability.startNotifier()
        }
        catch
        {
            print("Starting Reachability Notifier failed")
        }
    }
    
    private let reachabilityObject = Reachability()
}
